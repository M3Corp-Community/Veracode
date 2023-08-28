FROM veracode/api-wrapper-java:latest
RUN  curl -sSL https://download.sourceclear.com/ci.sh | bash -s scan --allow-dirty
RUN  java -jar /opt/veracode/api-wrapper.jar -vid $veracodeID -vkey $veracodekey -action uploadandscan -appname "$appName" -createprofile true -filepath "$caminhoArquivo" -version $numeroVersao 