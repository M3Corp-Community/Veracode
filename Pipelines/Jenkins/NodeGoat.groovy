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
                sh 'find . -name "*.js" -o -name "*.html" -o -name "*.htm" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.css" -o -name "*.jsp" -o -name "*.vue" | tar --exclude=./uploadToVeracode --exclude=./.git --exclude=./.gihtub -cvzf uploadToVeracode/nodegoat.tar.gz .'
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
                sh 'curl -o veracode-wrapper.jar https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/${wrapperVersion}/vosp-api-wrappers-java-${wrapperVersion}.jar'
                sh (""" java -jar veracode-wrapper.jar \
                    -vid "${VID}" \
                    -vkey "${VKEY}" \
                    -action uploadandscan \
                    -appname "NodeGoat-Demo" \
                    -createprofile false \
                    -filepath ${caminhoPacote} \
                    -createsandbox true \
                    -sandboxname "SANDBOX_1" \
                    -deleteincompletescan true \
                    -version "${BUILD_NUMBER}"
                 """)
                }
            }
        }
        
        stage('Veracode SAST - Policy Scan') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                sh 'curl -o veracode-wrapper.jar https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/${wrapperVersion}/vosp-api-wrappers-java-${wrapperVersion}.jar'
                sh (""" java -jar veracode-wrapper.jar \
                    -vid "${VID}" \
                    -vkey "${VKEY}" \
                    -action uploadandscan \
                    -appname "NodeGoat-Demo" \
                    -createprofile false \
                    -filepath ${caminhoPacote} \
                    -deleteincompletescan true \
                    -version "${BUILD_NUMBER}"
                 """)
                }
            }
        }

        stage('Veracode SAST - Pipeline Scan') { 
            steps {
                withCredentials([usernamePassword(credentialsId: 'veracode-credentials', passwordVariable: 'VKEY', usernameVariable: 'VID')]) {
                sh 'curl -sSO https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip'
                sh 'unzip -o pipeline-scan-LATEST.zip'
                sh (""" java -jar pipeline-scan.jar \
                    --veracode_api_id "${VID}" \
                    --veracode_api_key "${VKEY}" \
                    --file ${caminhoPacote} \
                    --project_name "NodeGoat-Demo" \
                    --policy_name "Veracode Recommended High"
                    """)
                }
            }
        }
    }
}