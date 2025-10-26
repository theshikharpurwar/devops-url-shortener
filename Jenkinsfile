pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'us-east-1'
        
        // ECR Configuration
        ECR_REGISTRY = '094822715133.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'url-shortener-api'
        IMAGE_TAG = "${BUILD_NUMBER}"
        
        // Application Configuration
        APP_NAME = 'url-shortener'
        APP_PORT = '8001'
        MONGO_CONTAINER = 'url-shortener-mongo'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out source code ==='
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker image ==='
                script {
                    sh """
                        docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REPOSITORY}:latest
                    """
                }
                echo "Built image: ${ECR_REPOSITORY}:${IMAGE_TAG}"
            }
        }
        
        stage('Login to AWS ECR') {
            steps {
                echo '=== Logging in to AWS ECR ==='
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                }
                echo 'Successfully logged in to ECR'
            }
        }
        
        stage('Push to ECR') {
            steps {
                echo '=== Pushing Docker image to ECR ==='
                script {
                    sh """
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY}:latest ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    """
                }
                echo "Pushed image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy') {
            steps {
                echo '=== Deploying application ==='
                script {
                    sh """
                        # Start MongoDB container if not running
                        docker ps -q -f name=${MONGO_CONTAINER} || \
                        docker run -d \
                            --name ${MONGO_CONTAINER} \
                            --restart unless-stopped \
                            -p 27017:27017 \
                            mongo:7.0-jammy
                        
                        # Wait for MongoDB to be ready
                        sleep 5
                        
                        # Stop and remove old app container if exists
                        docker stop ${APP_NAME} || true
                        docker rm ${APP_NAME} || true
                        
                        # Run new app container linked to MongoDB
                        docker run -d \
                            --name ${APP_NAME} \
                            --restart unless-stopped \
                            --link ${MONGO_CONTAINER}:mongo \
                            -p ${APP_PORT}:${APP_PORT} \
                            ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    """
                }
                echo "Application deployed on port ${APP_PORT}"
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '=== Cleaning up old images ==='
                script {
                    sh """
                        docker image prune -af --filter "until=24h"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '=== Pipeline completed successfully! ==='
            echo "✅ Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
            echo "✅ Application deployed at: http://98.84.35.193:${APP_PORT}"
        }
        
        failure {
            echo '=== Pipeline failed! ==='
            echo '❌ Check logs above for errors'
        }
        
        always {
            echo '=== Cleaning up workspace ==='
            sh """
                docker rmi ${ECR_REPOSITORY}:${IMAGE_TAG} || true
                docker rmi ${ECR_REPOSITORY}:latest || true
            """
            cleanWs()
        }
    }
}
