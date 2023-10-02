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
        
        post {
            always {
                archiveArtifacts artifacts: '**/dependency-check-report.xml', allowEmptyArchive: true
                // Schoonmaakstap (optioneel) - Stop en verwijder de container na gebruik
                sh 'docker stop $(docker ps -q --filter "ancestor=nextcloud:10.0.0")'
                sh 'docker rm $(docker ps -aq --filter "ancestor=nextcloud:10.0.0")'
            }
        }
    }
}    
