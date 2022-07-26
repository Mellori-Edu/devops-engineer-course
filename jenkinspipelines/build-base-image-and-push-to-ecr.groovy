def git_commit = ""
pipeline {
    agent {
        label params.AGENT
    }

    parameters {
        choice(name: "AGENT", choices: ["master"])
        
    }

    options {
        disableResume()
    }

    environment {
        PROJECT_NAME = "laraveldemo"
        // REGION = "ap-southeast-1"
        // ECR_BASE_URL = "813995029960.dkr.ecr.ap-southeast-1.amazonaws.com"
        // BASE_IMAGE = "${params.ECR_BASE_URL}/laravel-demo-base:latest"
    }

    stages {
        stage('Build Base') {
            steps {
                script {
                    sh """#!/bin/bash
                        // aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_BASE_URL}
                        // docker-compose -p ${PROJECT_NAME} -f docker-compose.yml build --no-cache base
                        // docker tag ${PROJECT_NAME}_base:latest ${BASE_IMAGE}
                        // docker push ${BASE_IMAGE}
                        // docker rmi ${BASE_IMAGE}

                    """
                }
            }
        }
    }
}