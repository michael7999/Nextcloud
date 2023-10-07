pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'nextcloud'
        DOCKER_IMAGE_TAG = '10.0.0'
        DOCKER_BUILD_COMMAND = "docker build --build-arg PHP_VERSION=7.4 --build-arg VARIANT=apache --build-arg DEBIAN_VERSION=buster -t nextcloud:10.0.0 ." 
        DOCKER_RUN_COMMAND = "docker run -d -p 8081:8081 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
        SNYK_API_TOKEN = credentials('snyk-api-token')
        PHP_VERSION = '8.0'
        VARIANT = 'apache'
        DEBIAN_VERSION = 'bullseye'
    }
    stages { 
        stage('Build Docker Image') {
            steps {
                sh script: "${DOCKER_BUILD_COMMAND}", returnStatus: true
                /*catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    error 'Docker build failed.'
                }*/
            }
        }
        stage('Run Docker Container') {
            steps {
                sh script: "${DOCKER_RUN_COMMAND}", returnStatus: true
                /*catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    error 'Docker container failed to start.'
                }*/
            }
        }
        stage('Snyk Authentication') {
            steps {
                script {
                    sh "/usr/bin/npx snyk auth ${SNYK_API_TOKEN}"
                }
             }
        }
        /*
        stage('Snyk scan') {
            steps {
                dir('/var/lib/jenkins/workspace/cybersec-pipeline/backend') {
                    sh 'npm install'
                    snykSecurity failOnError: false, severity: 'critical', snykInstallation: 'snyk', snykTokenId: 'SNYK_API_TOKEN', targetFile: 'package.json'
                }
            }
        }
        */
        stage('Snyk scan') {
            steps {
                script {
                    sh '/usr/bin/npx snyk test --all-projects --all-projects-depth=1 --all-projects-recursive --all-sub-projects-recursive --all-sub-projects-depth=1 --all-projects-tracked=auto --format=junit > snyk-results.xml'
                }
            }
        }
         stage('Scan Docker Container') {
          steps {
            echo 'Scanning your Docker container...'
            script {
              sh '/usr/bin/npx snyk container test  nextcloud:10.0.0 --format=jenkins > snyk-results.xml'  // Vervang 'your-docker-image' door de naam van je Docker-image
             
            }
            
            }
          }
    }
        /*
        stage('Snyk Security Scan') {
            steps {
                //sh """/usr/bin/npx snyk test --all-projects --all-projects-depth=1 --all-projects-recursive --all-sub-projects-recursive --all-sub-projects-depth=1 --all-projects-tracked=auto --token=${SNYK_API_TOKEN}"""
                sh "/usr/bin/npx snyk test /home/michael/Nextcloud/docker --all-projects --all-projects-depth=1 --all-projects-recursive --all-sub-projects-recursive --all-sub-projects-depth=1 --all-projects-tracked=auto"
            }
        }
        */
        /*
        stage('Snyk Security Scan') {
            steps {
                sh """/usr/bin/npx snyk test --all-projects --all-projects-depth=1 --all-projects-recursive --all-sub-projects-recursive --all-sub-projects-depth=1 --all-projects-tracked=auto --token=${SNYK_API_TOKEN}"""
            }
        }
        */
        /*stage('Scan Container Image for Vulnerabilities') {
            steps {
                script {
                    // Run Clair to scan the Docker image
                    clairImageName = 'nextcloud:10.0.0'
                    def clairScan = sh(script: "docker run -d --network host -p 6060:6060 --name clair arminc/clair-local-scan:latest", returnStatus: true)
                    if (clairScan == 0) {
                        sh(script: "docker run --network host -e CLAIR_ADDR=localhost:6060 -e DOCKER_IMAGE=${clairImageName} arminc/clair-scanner:latest")
                        sh 'docker stop clair'
                        sh 'docker rm clair'
                    } else {
                        error('Failed to start Clair scanner')
                    }
                }
            }
        }*/
    
    post {
        always {
            archiveArtifacts artifacts: '**/dependency-check-report.xml', allowEmptyArchive: true
            junit 'snyk-results.xml'
            publishSnykResults severity: 'high', testResultsFile: 'snyk-results.xml'
            // Schoonmaakstap (optioneel) - Stop en verwijder de container na gebruik
            sh 'docker stop $(docker ps -q --filter "ancestor=nextcloud:10.0.0")'
            sh 'docker rm $(docker ps -aq --filter "ancestor=nextcloud:10.0.0")'
        }
    }

}
   
