pipeline {
    agent any 
    environment {
        caminhoPacote = 'uploadToVeracode/nodegoat.tar.gz'
        wrapperVersion = '23.8.12.0'
    }
    stages {
        stage('Clean') { 
            steps {
                sh 'rm -rf pipeline-scan-LATEST.zip pipeline-scan.jar'
                sh 'rm -rf veracode-wrapper.jar'
                sh 'rm -rf uploadToVeracode'
            }
        }

        stage('Archive') { 
            steps {
                sh 'mkdir uploadToVeracode'
                sh 'find . -name "*.js" -o -name "*.html" -o -name "*.htm" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.css" -o -name "*.jsp" -o -name "*.vue" | tar --exclude=./uploadToVeracode --exclude=./.git --exclude=./.github -cvzf uploadToVeracode/nodegoat.tar.gz .'
            }
        }

        stage('Veracode SCA - Agent Scan') { 
            steps {
                withCredentials([string(credentialsId: 'SRCCLR_API_TOKEN', variable: 'SRCCLR_API_TOKEN')]) {
                    sh 'curl -sSL https://download.sourceclear.com/ci.sh | bash -s scan --update-advisor --uri-as-name || true'
                }
            }
        }

       stage('Veracode SAST - Sandbox Scan') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                    veracode applicationName: 'NodeGoat-Demo', createSandbox: true, criticality: 'VeryHigh', deleteIncompleteScanLevel: '2', sandboxName: 'SANDBOX_Jenkins', scanName: '"${BUILD_NUMBER}"', uploadIncludesPattern: "${caminhoPacote}", vid: "${VID}", vkey: "${VKEY}"      
                }
            }
        }

       stage('Veracode SAST - Policy Scan') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                    veracode applicationName: 'NodeGoat-Demo', createSandbox: false, criticality: 'VeryHigh', deleteIncompleteScanLevel: '2', scanName: '"${BUILD_NUMBER}"', uploadIncludesPattern: "${caminhoPacote}", vid: "${VID}", vkey: "${VKEY}"      
                }
            }
        }

        stage('Veracode SAST - Pipeline Scan') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                    sh 'curl -sSO https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip'
                    sh 'unzip -o pipeline-scan-LATEST.zip'
                    sh 'java -jar pipeline-scan.jar --veracode_api_id "${VID}" --veracode_api_key "${VKEY}" --file ${caminhoPacote} --project_name "Java-VeraDemo" || true'
                }
            }
        }        

        stage('Veracode SAST Pipeline Scan- Baseline File') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                    sh 'curl -sSO https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip'
                    sh 'unzip -o pipeline-scan-LATEST.zip'
                    
                    // SAST Pipeline Scan with results.json as baseline file to search only for new vulnerabilities compared with the last scan
                    sh 'java -jar pipeline-scan.jar --veracode_api_id "${VID}" --veracode_api_key "${VKEY}" --file ${caminhoPacote} --project_name "NodeGoat-Demo" --baseline_file results.json'
                }
            }    
        }
    }
}