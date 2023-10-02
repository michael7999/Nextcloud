pipeline {
    agent any
    stages {
        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                    script {
                        def additionalArguments = '''\
                            -o ./
                            -s ./
                            -f ALL
                            --prettyPrint
                        '''

 

                        dependencyCheck(
                            additionalArguments: additionalArguments,
                            odcInstallation: 'OWASP Dependency-Check Vulnerabilities'
                        )
                    }

 

                    dependencyCheckPublisher(pattern: 'dependency-check-report.xml')
                }
            }
        stage('Bouwen en uitvoeren Docker-container') {
            steps {
                script {
                    // Docker-container uitvoeren
                    sh 'docker run -d -p 8089:80 nextcloud:10.0.0'
                }
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
    post {
        always {
            archiveArtifacts artifacts: '**/dependency-check-report.xml', allowEmptyArchive: true
            // Schoonmaakstap (optioneel) - Stop en verwijder de container na gebruik
            sh 'docker stop $(docker ps -q --filter "ancestor=nextcloud:10.0.0")'
            sh 'docker rm $(docker ps -aq --filter "ancestor=nextcloud:10.0.0")'
        }
    }
}
