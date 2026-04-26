pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPO_NAME = 'attendance-app'
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

                    def rawBranch = env.GIT_BRANCH ?: env.BRANCH_NAME ?: 'manual'
                    rawBranch = rawBranch.replaceFirst(/^origin\\//, '')
                    env.BRANCH_TAG = rawBranch.replaceAll('[^A-Za-z0-9_.-]', '-')

                    env.AWS_ACCOUNT_ID = sh(
                        script: 'aws sts get-caller-identity --query Account --output text',
                        returnStdout: true
                    ).trim()

                    env.ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                    env.IMAGE_NAME = "${env.ECR_REGISTRY}/${env.ECR_REPO_NAME}"
                }

                sh '''
                    echo "Short SHA: ${SHORT_SHA}"
                    echo "Branch tag: ${BRANCH_TAG}"
                    echo "ECR registry: ${ECR_REGISTRY}"
                    echo "Image name: ${IMAGE_NAME}"
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Container Build') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Container Build'
                }

                sh '''
                    set -eux

                    docker build --pull \
                      -f ${APP_DIR}/Dockerfile \
                      -t ${IMAGE_NAME}:${SHORT_SHA} \
                      -t ${IMAGE_NAME}:${BRANCH_TAG} \
                      ${APP_DIR}

                    docker images | grep ${ECR_REPO_NAME}
                '''
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Security Scan'
                }

                sh '''
                    set -eux

                    mkdir -p trivy-reports

                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v "$PWD:/work" \
                      aquasec/trivy:latest image \
                      --timeout 10m \
                      --ignorefile /work/${APP_DIR}/.trivyignore \
                      --severity HIGH,CRITICAL \
                      --ignore-unfixed \
                      --exit-code 1 \
                      --format table \
                      --output /work/trivy-reports/trivy-image-report.txt \
                      ${IMAGE_NAME}:${SHORT_SHA}

                    cat trivy-reports/trivy-image-report.txt
                '''
            }
        }

        stage('Push') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Push'
                }

                sh '''
                    set -eux

                    aws ecr get-login-password --region ${AWS_REGION} \
                      | docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker push ${IMAGE_NAME}:${SHORT_SHA}
                    docker push ${IMAGE_NAME}:${BRANCH_TAG}
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-reports/trivy-image-report.txt', allowEmptyArchive: true
        }

        success {
            echo "SUCCESS: Docker image scanned and pushed to ECR."
            echo "Pushed tags: ${IMAGE_NAME}:${SHORT_SHA}, ${IMAGE_NAME}:${BRANCH_TAG}"
        }

        failure {
            echo "FAILURE: Pipeline failed at stage: ${CURRENT_STAGE}"
        }
    }
}
