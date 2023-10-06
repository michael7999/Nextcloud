pipeline {
    agent any
    environment {
        SNYK_API_TOKEN = credentials('snyk-api-token')
    }
    stages {
        stage('Build and Run Docker Container') {
            steps {
                script {
                    // Run the Docker container
                    sh 'docker run -d --network host -p 8089:80 nextcloud:10.0.0'
                }
            }
        }

        stage('Generate SBOM') {
            steps {
                sh 'curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin'
                sh 'syft cybersec-pipeline-todo-api-service --scope all-layers -o json > sbom-report.json'
            }
        }
        /*
        stage('Snyk Authentication') {
            steps {
                script {
                    sh "/usr/bin/npx snyk auth ${SNYK_API_TOKEN}"
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                sh "/usr/bin/npx snyk test ./Nextcloud/docker --all-projects --all-projects-depth=1 --all-projects-recursive --all-sub-projects-recursive --all-sub-projects-depth=1 --all-projects-tracked=auto"
            }
        }

        stage('Scan Container Image for Vulnerabilities') {
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
        }
    }
    */
    post {
        always {
            archiveArtifacts artifacts: '**/dependency-check-report.xml', allowEmptyArchive: true
            // Cleanup (optional) - Stop and remove the container after use
            sh 'docker stop $(docker ps -q --filter "ancestor=nextcloud:10.0.0")'
            sh 'docker rm $(docker ps -aq --filter "ancestor=nextcloud:10.0.0")'
        }
    }
}
