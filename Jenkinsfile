pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    // Add your build steps here
                    sh 'echo "Building..."'
                    // run bash/install.sh command
                    sh 'bash/install.sh'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    // Add your test steps here
                    sh 'echo "Testing..."'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Add your deploy steps here
                    sh 'echo "Deploying..."'
                }
            }
        }
    }
}