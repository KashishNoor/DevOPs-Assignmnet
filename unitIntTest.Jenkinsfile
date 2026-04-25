pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
    }

    stages {
        stage('Install Dependencies') {
            steps {
                dir('A04/app') {
                    sh 'npm ci'
                }
            }
        }

        stage('Build') {
            steps {
                dir('A04/app') {
                    sh 'npm run build'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('A04/app') {
                    sh 'npm run test:unit'
                }
            }
        }

        stage('Integration Tests') {
            steps {
                dir('A04/app') {
                    sh 'npm run test:integration'
                }
            }
        }
    }

    post {
        always {
            junit 'A04/app/reports/**/*.xml'
        }
    }
}
