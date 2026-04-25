pipeline {
    agent { label 'linux-agent' }

    stages {
        stage('Sanity Check') {
            steps {
                sh 'echo hello from linux-agent'
                sh 'hostname'
                sh 'java -version'
                sh 'git --version'
                sh 'docker --version'
                sh 'aws --version'
                sh 'terraform version'
            }
        }
    }
}