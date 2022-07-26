#!/usr/bin/env groovy -w
pipeline {
    agent {
        label params.AGENT
    }
    parameters {
        choice(name: "AGENT", choices: ["master"])
        string(name: 'PROJECT_NAME', defaultValue: 'laraveldemo', description: 'Enter project name')
        choice(name: 'ENVIRONMENT', choices: ['development'], description: 'Enter short environment name?')
        choice(name: 'SERVICE_NAME', choices: ['laravel-demo'], description: 'Name of ecr repo?')
    }
    environment {
        ENVIRONMENT = "${params.ENVIRONMENT}"
        PROJECT_NAME = "${params.PROJECT_NAME}"
        COMPOSE_PROJECT_NAME= "${params.PROJECT_NAME}${params.ENVIRONMENT}"
        SERVICE_NAME = "${params.SERVICE_NAME}"
        ECR_LOGIN_COMMAND = "aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 813995029960.dkr.ecr.ap-southeast-1.amazonaws.com"
        ECR_ADDRESS = "813995029960.dkr.ecr.ap-southeast-1.amazonaws.com"
    }
    options {
        disableResume()
        timeout(time: 1, unit: 'HOURS')
    }
    stages {
        stage("Build docker"){
            steps {
                sh '''#!/bin/bash
                    set -e
                    docker-compose -f docker-compose-${ENVIRONMENT}.yml --project-name ${COMPOSE_PROJECT_NAME} build --no-cache php
                    docker-compose -f docker-compose-${ENVIRONMENT}.yml --project-name ${COMPOSE_PROJECT_NAME} build --no-cache nginx
                '''
            }
        }

        stage("Push image to ECR"){
            steps {
                sh '''#!/bin/bash
                    set -e
                    eval ${ECR_LOGIN_COMMAND}
                    PHP_IMAGE=${ECR_ADDRESS}/${SERVICE_NAME}-php:${GIT_COMMIT}
                    docker tag ${COMPOSE_PROJECT_NAME}_php ${PHP_IMAGE}
                    docker push ${PHP_IMAGE}
                    docker rmi ${PHP_IMAGE}

                    NGINX_IMAGE=${ECR_ADDRESS}/${SERVICE_NAME}-nginx:${GIT_COMMIT}
                    docker tag ${COMPOSE_PROJECT_NAME}_nginx ${NGINX_IMAGE}
                    docker push ${NGINX_IMAGE}
                    docker rmi ${NGINX_IMAGE}
                '''
            }
        }

        stage("Deploy code"){
            steps {
                sh '''#!/bin/bash
                    set -e
                    set -x
                    echo "Deploy code"
                    python3 scripts/deploy-ecs-backend-service.py ${SERVICE_NAME} ${ENVIRONMENT} ${GIT_COMMIT}
                '''
            }
        }


    }
}