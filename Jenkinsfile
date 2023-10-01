pipeline {
    agent any
    stages {
        stage('Bouwen en uitvoeren Docker-container') {
            steps {
                script {
                    // Docker-container uitvoeren
                    sh 'docker run -d -p 8089:80 nextcloud'
                }
            }
        }
        // Voeg hier andere stappen toe aan je CI/CD-pipeline
    }
    post {
        always {
            // Schoonmaakstap (optioneel) - Stop en verwijder de container na gebruik
            sh 'docker stop $(docker ps -q --filter "ancestor=nextcloud")'
            sh 'docker rm $(docker ps -aq --filter "ancestor=nextcloud")'
        }
    }
}
