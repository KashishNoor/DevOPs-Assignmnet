pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'eu-north-1'
        PROJECT_NAME = 'kashish'

        PROD_LISTENER_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:listener/app/kashish-bluegreen-alb/caf362ce26b598bb/6bffd452540a0ab3'
        SMOKE_LISTENER_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:listener/app/kashish-bluegreen-alb/caf362ce26b598bb/0001e1467f213349'

        TG_BLUE_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:targetgroup/kashish-tg-blue/3ff0013e724e69ac'
        TG_GREEN_ARN = 'arn:aws:elasticloadbalancing:eu-north-1:188876037443:targetgroup/kashish-tg-green/ea9b8fb03c20917e'

        ALB_DNS = 'kashish-bluegreen-alb-1365040639.eu-north-1.elb.amazonaws.com'

        DEPLOY_LOG_BUCKET = 'kashish-bluegreen-deploy-188876037443'
        DEPLOY_LOG_KEY = 'bluegreen/deployments.jsonl'

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
                }

                sh '''
                    echo "Rollback pipeline checkout complete"
                    echo "Git SHA: ${SHORT_SHA}"
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Detect Live Color') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Detect Live Color'
                }

                sh '''
                    set -eux

                    LIVE_TG=$(aws elbv2 describe-listeners \
                      --listener-arns "${PROD_LISTENER_ARN}" \
                      --query "Listeners[0].DefaultActions[0].TargetGroupArn" \
                      --output text)

                    if [ "$LIVE_TG" = "$TG_BLUE_ARN" ]; then
                      LIVE_COLOR="blue"
                      ROLLBACK_COLOR="green"
                      ROLLBACK_TG="$TG_GREEN_ARN"
                    else
                      LIVE_COLOR="green"
                      ROLLBACK_COLOR="blue"
                      ROLLBACK_TG="$TG_BLUE_ARN"
                    fi

                    echo "$LIVE_COLOR" > live-color.txt
                    echo "$ROLLBACK_COLOR" > rollback-color.txt
                    echo "$ROLLBACK_TG" > rollback-target-group.txt

                    echo "Current production color: $LIVE_COLOR"
                    echo "Rollback target color: $ROLLBACK_COLOR"
                '''
            }
        }

        stage('Rollback Smoke Test') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Rollback Smoke Test'
                }

                sh '''
                    set -eux

                    ROLLBACK_TG=$(cat rollback-target-group.txt)
                    ROLLBACK_COLOR=$(cat rollback-color.txt)

                    aws elbv2 modify-listener \
                      --listener-arn "$SMOKE_LISTENER_ARN" \
                      --default-actions Type=forward,TargetGroupArn="$ROLLBACK_TG"

                    echo "Running smoke test for rollback color $ROLLBACK_COLOR"
                    curl -f "http://${ALB_DNS}:8081/health"
                '''
            }
        }

        stage('Switch Production') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Switch Production'
                }

                sh '''
                    set -eux

                    LIVE_COLOR=$(cat live-color.txt)
                    ROLLBACK_COLOR=$(cat rollback-color.txt)
                    ROLLBACK_TG=$(cat rollback-target-group.txt)

                    aws elbv2 modify-listener \
                      --listener-arn "$PROD_LISTENER_ARN" \
                      --default-actions Type=forward,TargetGroupArn="$ROLLBACK_TG"

                    RESULT="rollback-success"
                    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

                    echo "{\"timestamp\":\"$TIMESTAMP\",\"git_sha\":\"${SHORT_SHA}\",\"previous_color\":\"$LIVE_COLOR\",\"new_color\":\"$ROLLBACK_COLOR\",\"result\":\"$RESULT\"}" > rollback-entry.jsonl

                    aws s3 cp "s3://${DEPLOY_LOG_BUCKET}/${DEPLOY_LOG_KEY}" deployments-existing.jsonl || true
                    cat deployments-existing.jsonl rollback-entry.jsonl > deployments-updated.jsonl
                    aws s3 cp deployments-updated.jsonl "s3://${DEPLOY_LOG_BUCKET}/${DEPLOY_LOG_KEY}"
                '''
            }
        }
    }

    post {
        success {
            echo 'Blue-Green rollback completed successfully.'
        }

        failure {
            echo "Blue-Green rollback failed at stage: ${env.CURRENT_STAGE}"
        }

        always {
            archiveArtifacts artifacts: 'live-color.txt, rollback-color.txt, rollback-target-group.txt, rollback-entry.jsonl, deployments-updated.jsonl', allowEmptyArchive: true
        }
    }
}
