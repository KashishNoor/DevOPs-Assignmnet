pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
        skipDefaultCheckout(true)
    }

    parameters {
        string(name: 'SONAR_HOST_URL', defaultValue: 'http://SONARQUBE_PRIVATE_IP:9000', description: 'SonarQube URL reachable from the Jenkins agent (prefer private IP inside VPC).')
        string(name: 'SONAR_PROJECT_KEY', defaultValue: 'attendance-app', description: 'Unique project key in SonarQube.')
        string(name: 'SONAR_PROJECT_NAME', defaultValue: 'Attendance App', description: 'Display name in SonarQube.')
    }

    environment {
        APP_DIR = 'app'
        CURRENT_STAGE = 'Pipeline started'
        // Create this credential in Jenkins as a "Secret text" (example id: sonarqube-token)
        SONAR_TOKEN = credentials('sonarqube-token')
        NODE_IMAGE = 'node:20-bullseye'
    }

    stages {
        stage('Checkout') {
            steps {
                script { env.CURRENT_STAGE = 'Checkout' }
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                script { env.CURRENT_STAGE = 'Build & Test' }
                dir("${env.APP_DIR}") {
                    // Run Node/npm inside a container so the agent doesn't need npm installed.
                    sh '''
                        set -eux
                        docker run --rm \
                          -v "$(pwd):/work" \
                          -w /work \
                          "${NODE_IMAGE}" \
                          bash -lc "npm ci && npm run build && npm run test:coverage"
                    '''
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                script { env.CURRENT_STAGE = 'SonarQube Scan' }
                dir("${env.APP_DIR}") {
                    sh '''
                        set -eux
                        docker run --rm \
                          -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
                          -e SONAR_TOKEN="${SONAR_TOKEN}" \
                          -v "$(pwd):/usr/src" \
                          sonarsource/sonar-scanner-cli:latest \
                          -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                          -Dsonar.sources=src \
                          -Dsonar.tests=tests \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'app/coverage/**, app/reports/**', allowEmptyArchive: true
        }
        failure {
            echo "Failed at stage: ${CURRENT_STAGE}"
        }
    }
}
