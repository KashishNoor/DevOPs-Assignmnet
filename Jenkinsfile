pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
    }

    stages {
        stage('Check App') {
            steps {
                script {
                    env.HAS_A04_APP = fileExists('A04/app/package.json') ? 'true' : 'false'
                    if (env.HAS_A04_APP == 'true') {
                        echo 'A04 app found. Running unit and integration tests.'
                    } else {
                        echo 'A04 app not found on this branch. Skipping app test stages.'
                    }
                }
            }
        }

        stage('Install Dependencies') {
            when {
                expression { env.HAS_A04_APP == 'true' }
            }
            steps {
                dir('A04/app') {
                    sh 'npm ci'
                }
            }
        }

        stage('Build') {
            when {
                expression { env.HAS_A04_APP == 'true' }
            }
            steps {
                dir('A04/app') {
                    sh 'npm run build'
                }
            }
        }

        stage('Unit Tests') {
            when {
                expression { env.HAS_A04_APP == 'true' }
            }
            steps {
                dir('A04/app') {
                    sh 'npm run test:unit'
                }
            }
        }

        stage('Integration Tests') {
            when {
                expression { env.HAS_A04_APP == 'true' }
            }
            steps {
                dir('A04/app') {
                    sh 'npm run test:integration'
                }
            }
        }
    }

    post {
        always {
            junit testResults: 'A04/app/reports/**/*.xml', allowEmptyResults: true
        }
    }
}
