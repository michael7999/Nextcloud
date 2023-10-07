pipeline {
    agent any
    environment {
        APP_IP = credentials('APP_IP')
        SNYK_TOKEN = credentials('SNYK_TOKEN')
    }
    stages {               
        stage('Bouwen en uitvoeren Docker-container') {
            steps {
                script {
                    // Docker-container uitvoeren
                    sh 'docker run -d -p 8089:80 --name nextCloud nextcloud:10.0.0'
                }
            }
        }
        // stage('Generate SBOM') {
        //     steps {
        //         sh 'curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin'
        //         sh 'syft nextcloud:10.0.0 --scope all-layers -o json > sbom-report.json'
        //     }
        // }
        stage('Dynamic Testing') {
            steps {
                sh "nikto -h ${APP_IP} > nikto-report.json"                
            }
        }
        stage('Port scan'){
            steps {
                sh "nmap ${APP_IP} > nmap-report.json"
            }
        }
        stage('Snyk Authentication') {
            steps {
                script {
                    sh "/usr/bin/npx snyk auth ${SNYK_TOKEN}"
                }
             }
        }
        stage('Snyk scan') {
            steps {
                script {
                    sh 'docker build -t my-nextcloud-image:1.0 .'
                    sh 'snyk container test my-nextcloud-image:1.0 --file=/path/to/Dockerfile --all-projects --json-file=snyk-results.json'
                }
            }
        }
        /*
        stage('Vault'){
            steps {
                withVault(configuration: [timeout: 60, vaultCredentialId: 'Vault-Jenkins-AppRole', vaultUrl: 'http://127.0.0.1:8200', vaultSecrets: [[ engineVersion: 2, path: 'secret/dev-creds/git-pass', secretValues: 1]] ])
            }
        }
        */
        /*stage('Debricked Scan') {
            steps {
                script {
                    sh 'curl -L https://github.com/debricked/cli/releases/latest/download/cli_linux_x86_64.tar.gz | tar -xz debricked'
                    sh './debricked scan -r cybersec-demo-app -t $DEBRICKED_TOKEN'
                }
            }
        }*/
    }
    post {
        always {
            archiveArtifacts artifacts: '**/sbom-report.json', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/nikto-report', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/nmap-report', allowEmptyArchive: true
            sh 'docker stop nextCloud'
            sh 'docker rm nextCloud'
        }
    }
}
