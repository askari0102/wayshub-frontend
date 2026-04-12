pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "dwkelompok2"  // Ganti dengan username Docker Hub
        IMAGE_NAME = "wayshub-frontend" // Repo docker hub
        TAG = "production"
    }

    stages {
        
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/askari0102/wayshub-frontend.git'
            }
        }

        stage('Install Dependencies & Test') {
            steps {
                sh """
                npm install
                npm run test
                """
            }
        }
        
        stage('Build Image') {
            steps {
                sh """
                docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$TAG .
                """
            }
        }

        stage('Login & Push Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push $DOCKERHUB_USER/$IMAGE_NAME:$TAG
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['k2ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no kelompok2@10.98.118.3 "
                    cd /home/kelompok2/wayshub &&
                    docker compose pull frontend &&
                    docker compose up -d frontend nginx
                    "
                    """
                }
            }
        }
    }
}