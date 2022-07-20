# Credenciais
veracodeID="Disponivel no portal da Veracode"
veracodeAPIkey="Disponivel no portal da Veracode"
export SRCCLR_API_TOKEN="Disponivel no portal da Veracode"

# Configuracoes
appName="Nome da aplicação"
caminhoArquivo="$appName.zip"
numeroVersao=$(date +%H%M%s%d%m%y)

# Pipeline Scan
curl -sSO https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip
unzip pipeline-scan-LATEST.zip
java -jar pipeline-scan.jar -vid $veracodeID -vkey $veracodeAPIkey -f $caminhoArquivo --issue_details true

# SCA Simples
curl -sSL 'https://download.sourceclear.com/ci.sh' | bash -s – scan

# SCA - Commit de atualização de versões
curl -sSL 'https://download.sourceclear.com/ci.sh' | bash -s – scan --update-advisor --pull-request

# Wrapper API
urlDownloadAPI="https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/20.12.7.3/vosp-api-wrappers-java-20.12.7.3.jar"
curl -L -o VeracodeJavaAPI.jar $urlDownloadAPI
java -jar VeracodeJavaAPI.jar \
    -vid $veracodeID -vkey $veracodeAPIkey \
    -action uploadandscan \
    -appname "$appName" \
    -filepath "$caminhoArquivo" \
    -version $numeroVersao \
    -createprofile true \
    -scantimeout 60
