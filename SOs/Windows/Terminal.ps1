# SCA
iex ((New-Object System.Net.WebClient).DownloadString('https://download.srcclr.com/ci.ps1')) # Faz o download do script
srcclr scan --update-advisor --allow-dirty # Executa o scan


# Pipeline Scan
java -jar "pipeline-scan.jar" -vid $veracodeID -vkey $veracodeAPIkey -f $caminhoarquivo 


# API Wrapper
$numeroVersao = Get-Date -Format hhmmssddMMyy # Cria um hash com base no dia e hora para numero de versão
VeracodeAPI.exe -vid $veracodeID -vkey $veracodeAPIkey -action UploadAndScan -appname "$NomeApp" -createprofile true -filepath "$caminhoArquivo" -version $numeroVersao

# Wrapper com SandBox
VeracodeAPI.exe -vid $veracodeID -vkey $veracodeAPIkey -action UploadAndScan -appname "$NomeApp" -createprofile true -sandboxname "NOME" -createsandbox true -filepath "$caminhoArquivo" -version $numeroVersao