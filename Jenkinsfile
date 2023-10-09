pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'nextcloud'
        DOCKER_IMAGE_TAG = '23.0.10'
        DOCKER_BUILD_COMMAND = "docker build --build-arg PHP_VERSION=7.4 --build-arg VARIANT=apache --build-arg DEBIAN_VERSION=buster -t nextcloud:23.0.10 ." 
        DOCKER_RUN_COMMAND = "docker run -d --name nextCloud -p 8081:80 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
        APP_IP = credentials('APP_IP')
        SNYK_TOKEN = credentials('SNYK_TOKEN')
        NIKTO = credentials('nikto_ip_port')
    }
    stages {
        stage('Run Docker Container') {
            steps {
                sh script: "${DOCKER_RUN_COMMAND}", returnStatus: true
            }
        }
        // stage('Generate SBOM') {
        //     steps {
        //         sh 'curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin'
        //         sh 'syft nextcloud:23.0.10 --scope all-layers -o json > sbom-report.json'
        //     }
        // }
        stage('Dynamic Testing') {
            steps {
                script {
                    try {
                        sh "curl ${NIKTO}"
                        sh "nikto -h ${NIKTO} > nikto-report.json"
                    } catch (Exception e) {
                        echo "Snyk scan completed with vulnerabilities, but the stage will not fail."
                    } 
                }                            
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
        // stage('Snyk scan') {
        //     steps {
        //         script {
        //             try {
        //                 sh 'snyk container test nextcloud:23.0.10 --file=Dockerfile > dependency-check-report.txt'
        //             } catch (Exception e) {
        //                 echo "Snyk scan completed with vulnerabilities, but the stage will not fail."
        //             }
        //         }
        //     }
        // }
        stage("Clone") {
            steps {
               git url: "${SNYK_TOKEN}", branch: 'kelvinTest' //example file
               sh 'zip -r nextCloud.zip .'
            }
        }
        stage("Scan") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'codethreat_credentials', usernameVariable: 'username', passwordVariable: 'password')]) {
                    CodeThreatScan(
                        ctServer: env.ctServer_URL,
                        fileName:"nextCloud.zip",
                        maxNumberOfHigh: 23,
                        maxNumberOfCritical: 23,
                        weaknessIs: ".*injection,buffer.over.read,mass.assigment", 
                        condition: "OR",
                        project_name: "nextCloudProject",
                        credentialsId: "codethreat_credentials",
                        organization_name: "kelvin-ap@github"
                   )
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
            archiveArtifacts artifacts: '**/nikto-report.json', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/nmap-report.json', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/dependency-check-report.txt', allowEmptyArchive: true
            sh 'docker stop nextCloud'
            sh 'docker rm nextCloud'
        }
    }
}

