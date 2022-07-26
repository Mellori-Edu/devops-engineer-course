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
        timeout(time: 1, unit: 'HOURS')
    }

    stages {
        stage('Build Base') {
            steps {
                script {
                    sh """#!/bin/bash
                        make build_base
                        

                    """
                }
            }
        }
    }
}