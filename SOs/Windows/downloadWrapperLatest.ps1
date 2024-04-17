# Recebe a versao mais recente
[xml]$veracodeWrapperVersionList = curl https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/maven-metadata.xml
$veracodeWrapperVersion = $veracodeWrapperVersionList.metadata.versioning.latest

# Configura a URL e faz o download
$wrapperDownloadURL = "https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/23.4.11.2/vosp-api-wrappers-java-$veracodeWrapperVersion"
curl -o veracode-wrapper.jar $wrapperDownloadURL