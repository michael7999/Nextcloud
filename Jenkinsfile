pipeline {
    agent any
    environment {
        APP_IP = credentials('APP_IP')
    }
    stages { 
        stage('Create Docker Image') {
            steps {
                script {
                    sh 'docker commit nextCloud nextcloud-custom:10.0.0'
                }
            }
        }      
        stage('Bouwen en uitvoeren Docker-container') {
            steps {
                script {
                    // Docker-container uitvoeren
                    sh 'docker run -d -p 8089:80 --name nextCloudCustom nextcloud-custom:10.0.0'
                }
            }
        }
        stage('Generate SBOM') {
            steps {
                sh 'curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin'
                sh 'syft nextcloud-custom --scope all-layers -o json > sbom-report.json'
            }
        }
        stage('Dynamic Testing') {
            steps {
                sh 'nikto -h $APP_IP > nikto-report'                
            }
        }
        stage('Port scan'){
            steps {
                sh 'nmap $APP_IP > nmap-report'
            }
        }
        stage('Snyk scan') {
            steps {
                dir('/var/lib/jenkins/workspace/nextcloudPipe') {
                    sh 'npm install'
                    snykSecurity failOnError: false, severity: 'critical', snykInstallation: 'nextCloud', snykTokenId: 'SNYK_TOKEN', targetFile: 'package.json'
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
            sh 'docker rm nextCloud'
            sh 'docker rmi nextcloud-custom:10.0.0'
        }
    }
}
