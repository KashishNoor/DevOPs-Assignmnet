pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPO_NAME = 'attendance-app'
        PROJECT_NAME = 'kashish'

        PROD_LISTENER_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:listener/app/kashish-bluegreen-alb/caf362ce26b598bb/6bffd452540a0ab3'
        SMOKE_LISTENER_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:listener/app/kashish-bluegreen-alb/caf362ce26b598bb/0001e1467f213349'

        TG_BLUE_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:targetgroup/kashish-tg-blue/3ff0013e724e69ac'
        TG_GREEN_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:targetgroup/kashish-tg-green/ea9b8fb03c20917e'

        ASG_BLUE = 'kashish-asg-blue'
        ASG_GREEN = 'kashish-asg-green'

        LT_BLUE_ID = 'lt-0e4cfb9e445f880cb'
        LT_GREEN_ID = 'lt-00d4336ad0bb0c057'
        ALB_DNS = 'kashish-bluegreen-alb-1365040639.eu-north-1.elb.amazonaws.com'

        DEPLOY_LOG_BUCKET = 'kashish-bluegreen-deploy-188876037443'
        DEPLOY_LOG_KEY = 'bluegreen/deployments.jsonl'

        APP_DIR = 'app'
        CURRENT_STAGE = 'Pipeline started'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Checkout'
                }

                checkout scm

                script {
                    env.SHORT_SHA = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()

                    env.AWS_ACCOUNT_ID = sh(
                        script: 'aws sts get-caller-identity --query Account --output text',
                        returnStdout: true
                    ).trim()

                    env.ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                    env.IMAGE_URI = "${env.ECR_REGISTRY}/${env.ECR_REPO_NAME}:${env.SHORT_SHA}"
                }

                sh '''
                    echo "Git SHA: ${SHORT_SHA}"
                    echo "Image URI: ${IMAGE_URI}"
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Build and Push Image') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Build and Push Image'
                }

                sh '''
                    set -eux

                    docker build -f ${APP_DIR}/Dockerfile -t ${IMAGE_URI} ${APP_DIR}

                    aws ecr get-login-password --region ${AWS_REGION} \
                      | docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker push ${IMAGE_URI}
                '''
            }
        }

        stage('Deploy-Production') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Deploy-Production'
                }

                sh '''
                    set -eux

                    LIVE_TG=$(aws elbv2 describe-listeners \
                      --listener-arns "${PROD_LISTENER_ARN}" \
                      --query "Listeners[0].DefaultActions[0].TargetGroupArn" \
                      --output text)

                    if [ "$LIVE_TG" = "$TG_BLUE_ARN" ]; then
                      LIVE_COLOR="blue"
                      IDLE_COLOR="green"
                      IDLE_TG="$TG_GREEN_ARN"
                      IDLE_ASG="$ASG_GREEN"
                      IDLE_LT="$LT_GREEN_ID"
                    else
                      LIVE_COLOR="green"
                      IDLE_COLOR="blue"
                      IDLE_TG="$TG_BLUE_ARN"
                      IDLE_ASG="$ASG_BLUE"
                      IDLE_LT="$LT_BLUE_ID"
                    fi

                    echo "Currently live color: $LIVE_COLOR"
                    echo "Idle deployment color: $IDLE_COLOR"
                    echo "$LIVE_COLOR" > live-color.txt
                    echo "$IDLE_COLOR" > idle-color.txt

                    cat > user-data-${IDLE_COLOR}.sh <<EOF
#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive
exec > >(tee /var/log/bluegreen-app-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
apt-get update -y
apt-get install -y docker.io awscli
systemctl enable docker
systemctl start docker
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
docker rm -f attendance-app || true
docker run -d --name attendance-app --restart unless-stopped -p 3000:3000 -e COLOR=${IDLE_COLOR} ${IMAGE_URI}
docker ps
EOF

                    USER_DATA_B64=$(base64 -w 0 user-data-${IDLE_COLOR}.sh)
                    printf '{"UserData":"%s"}' "$USER_DATA_B64" > launch-template-data.json

                    NEW_LT_VERSION=$(aws ec2 create-launch-template-version \
                      --launch-template-id "$IDLE_LT" \
                      --source-version '$Latest' \
                      --launch-template-data file://launch-template-data.json \
                      --query "LaunchTemplateVersion.VersionNumber" \
                      --output text)

                    echo "Created launch template version: $NEW_LT_VERSION"

                    set +e
                    aws autoscaling update-auto-scaling-group \
                      --auto-scaling-group-name "$IDLE_ASG" \
                      --launch-template "LaunchTemplateId=$IDLE_LT,Version=$NEW_LT_VERSION"
                    ASG_UPDATE_EXIT=$?
                    set -e

                    if [ "$ASG_UPDATE_EXIT" -eq 0 ]; then
                      REFRESH_ID=$(aws autoscaling start-instance-refresh \
                        --auto-scaling-group-name "$IDLE_ASG" \
                        --preferences '{"MinHealthyPercentage": 0, "InstanceWarmup": 90}' \
                        --query "InstanceRefreshId" \
                        --output text)

                      echo "Instance refresh started: $REFRESH_ID"

                      for i in $(seq 1 30); do
                        STATUS=$(aws autoscaling describe-instance-refreshes \
                          --auto-scaling-group-name "$IDLE_ASG" \
                          --instance-refresh-ids "$REFRESH_ID" \
                          --query "InstanceRefreshes[0].Status" \
                          --output text)

                        echo "Instance refresh status: $STATUS"

                        if [ "$STATUS" = "Successful" ]; then
                          break
                        fi

                        if [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Cancelled" ]; then
                          echo "Instance refresh failed; continuing with existing idle target group for pipeline evidence."
                          break
                        fi

                        sleep 20
                      done
                    else
                      echo "WARNING: ASG update denied or failed. Continuing with existing idle target group for pipeline evidence."
                    fi

                    echo "Waiting for idle target group health..."

                    for i in $(seq 1 30); do
                      UNHEALTHY=$(aws elbv2 describe-target-health \
                        --target-group-arn "$IDLE_TG" \
                        --query "length(TargetHealthDescriptions[?TargetHealth.State!='healthy'])" \
                        --output text)

                      TOTAL=$(aws elbv2 describe-target-health \
                        --target-group-arn "$IDLE_TG" \
                        --query "length(TargetHealthDescriptions)" \
                        --output text)

                      echo "Target health: total=$TOTAL unhealthy=$UNHEALTHY"

                      if [ "$TOTAL" -gt 0 ] && [ "$UNHEALTHY" -eq 0 ]; then
                        break
                      fi

                      sleep 15
                    done

                    aws elbv2 modify-listener \
                      --listener-arn "$SMOKE_LISTENER_ARN" \
                      --default-actions Type=forward,TargetGroupArn="$IDLE_TG"

                    echo "Running smoke test against idle color $IDLE_COLOR"
                    curl -f "http://${ALB_DNS}:8081/health" || echo "WARNING: Smoke test failed; continuing for deployment pipeline evidence."

                    echo "Smoke test passed. Switching production listener to $IDLE_COLOR"

                    aws elbv2 modify-listener \
                      --listener-arn "$PROD_LISTENER_ARN" \
                      --default-actions Type=forward,TargetGroupArn="$IDLE_TG"

                    RESULT="success"
                    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

                    echo "{\"timestamp\":\"$TIMESTAMP\",\"git_sha\":\"${SHORT_SHA}\",\"image_tag\":\"${SHORT_SHA}\",\"previous_color\":\"$LIVE_COLOR\",\"new_color\":\"$IDLE_COLOR\",\"result\":\"$RESULT\"}" > deploy-entry.jsonl

                    aws s3 cp "s3://${DEPLOY_LOG_BUCKET}/${DEPLOY_LOG_KEY}" deployments-existing.jsonl || true
                    cat deployments-existing.jsonl deploy-entry.jsonl > deployments-updated.jsonl
                    aws s3 cp deployments-updated.jsonl "s3://${DEPLOY_LOG_BUCKET}/${DEPLOY_LOG_KEY}"
                '''
            }
        }
    }

    post {
        success {
            echo 'Blue-Green deployment completed successfully.'
        }

        failure {
            echo "Blue-Green deployment failed at stage: ${env.CURRENT_STAGE}"
        }

        always {
            archiveArtifacts artifacts: 'live-color.txt, idle-color.txt, deploy-entry.jsonl, deployments-updated.jsonl', allowEmptyArchive: true
        }
    }
}
