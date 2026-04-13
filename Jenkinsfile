pipeline {
    agent any
    tools {
        nodejs 'node14'
    }
    environment {
        DOCKERHUB_USER = "dwkelompok2"
        IMAGE_NAME = "wayshub-frontend"
        TAG = "production"
        DISCORD_WEBHOOK = credentials('discord-webhook')
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
                npm ci
                npm run test -- --watchAll=false
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
    post {
        success {
            sh """
            curl -H "Content-Type: application/json" \
            -X POST \
            -d '{
                "embeds": [{
                    "title": "✅ Deploy Berhasil!",
                    "description": "**wayshub-frontend** berhasil di-deploy ke production",
                    "color": 3066993,
                    "fields": [
                        {"name": "Branch", "value": "main", "inline": true},
                        {"name": "Tag", "value": "${TAG}", "inline": true},
                        {"name": "Build", "value": "#${BUILD_NUMBER}", "inline": true}
                    ]
                }]
            }' \
            $DISCORD_WEBHOOK
            """
        }
        failure {
            sh """
            curl -H "Content-Type: application/json" \
            -X POST \
            -d '{
                "embeds": [{
                    "title": "❌ Deploy Gagal!",
                    "description": "**wayshub-frontend** gagal di-deploy",
                    "color": 15158332,
                    "fields": [
                        {"name": "Branch", "value": "main", "inline": true},
                        {"name": "Build", "value": "#${BUILD_NUMBER}", "inline": true}
                    ]
                }]
            }' \
            $DISCORD_WEBHOOK
            """
        }
    }
}