node {
    stage('Git Clone') {
      git "https://github.com/lucasferreiram3/Verademo_Java.git"
   }
   
   stage('Build - Maven') {
       sh 'rm -rf target/'
       sh 'mvn clean package'
       sh 'ls -l target/ | grep war'
   }
   
   stage('Veracode SCA - Software Composition Analisys') {
       withCredentials([string(credentialsId: 'SRCCLR_API_TOKEN', variable: 'SRCCLR_API_TOKEN')]) {
            sh 'curl -sSL https://download.sourceclear.com/ci.sh | bash -s scan --update-advisor || true'
        }
   }

   stage('Veracode - Download Pipeline Scan') {
       sh 'rm -rf pipeline-scan-LATEST.zip pipeline-scan.jar'
       sh 'curl -O https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip'
       sh 'unzip pipeline-scan-LATEST.zip pipeline-scan.jar'
       sh 'ls -l | grep pipeline-scan.jar'
       
   }
   
   stage('Veracode SAST - Pipeline Scan') {
       withCredentials([usernamePassword(credentialsId: 'veracode_credentials', passwordVariable: 'VERACODE_KEY', usernameVariable: 'VERACODE_ID')]) {
            sh (""" java -jar pipeline-scan.jar \
                    --veracode_api_id "${VERACODE_ID}" \
                    --veracode_api_key "${VERACODE_KEY}" \
                    --file target/verademo.war \
                    --project_name "Java-VeraDemo" \
                    --json_output_file true \
                    --json_output_file="results.json" \
                    --issue_details true \
                    --fail_on_severity "Very High"
            """)
            
        }
   }
   
   stage('Veracode SAST - Sandbox Scan') {
       withCredentials([usernamePassword(credentialsId: 'veracode_credentials', passwordVariable: 'VERACODE_KEY', usernameVariable: 'VERACODE_ID')]) {
          veracode applicationName: 'Java-VeraDemo',
          criticality: 'VeryHigh', 
          deleteIncompleteScan: true,
          createSandbox: true,
          sandboxName: 'SANDBOX_1',
          scanName: '${BUILD_TIMESTAMP} - ${BUILD_NUMBER}', 
          uploadIncludesPattern: '**/**.war', 
          vid: "${VERACODE_ID}", 
          vkey: "${VERACODE_KEY}"
            
        }
   }

   stage('Veracode SAST - Policy Scan') {
       withCredentials([usernamePassword(credentialsId: 'veracode_credentials', passwordVariable: 'VERACODE_KEY', usernameVariable: 'VERACODE_ID')]) {
          veracode applicationName: 'Java-VeraDemo',
          canFailJob: true,
          criticality: 'VeryHigh', 
          debug: true, 
          deleteIncompleteScan: true, 
          scanName: '${BUILD_TIMESTAMP} - ${BUILD_NUMBER}', 
          timeout: 60, 
          uploadIncludesPattern: '**/**.war', 
          vid: "${VERACODE_ID}", 
          vkey: "${VERACODE_KEY}", 
          waitForScan: false
        }
   }
}