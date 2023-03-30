param (
    [parameter(position=0,Mandatory=$True)]
    $VeracodeID,
    [parameter(position=1,Mandatory=$True)]
    $VeracodeKey,
    [parameter(position=2)]
    $pastaferramenta = "$env:USERPROFILE/.veracode"
)

# Cria as pastas
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE/.veracode"
New-Item -ItemType Directory -Force -Path "$pastaferramenta"

# Adiciona o caminho no Path do sistema
if ($env:Path -NotContains $pastaferramenta) {
    Write-Host "Add $pastaferramenta ao path"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$pastaferramenta", 'User')
}

# Cria o arquivo de credenciais
$templateCredenciais = @"
[default]
veracode_api_key_id = $VeracodeID
veracode_api_key_secret = $VeracodeKey
"@
Write-Host "Criando arquivo de credenciais"
Set-Content -Path "$env:USERPROFILE/.veracode/credentials" -Value "$templateCredenciais"

# Download e configuração: Pipeline Scan
Write-Host "Configurando: Pipeline Scan"
$urlDownload = "https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip" # Define a url de download
$caminhoDownload = "$env:LOCALAPPDATA/VeracodePipeline.zip" # Define um caminho para o arquivo de download
Invoke-WebRequest -Uri "$urlDownload" -OutFile "$caminhoDownload" # Faz o download
Expand-Archive -Path "$caminhoDownload" -DestinationPath "$pastaferramenta" -Force # Descompacta o ZIP para uma pasta
Remove-Item "$caminhoDownload" # Remove o arquivo de download

# Download e configuração: API Wrapper
Write-Host "Configurando: Wrapper"
$urlDownload = "https://tools.veracode.com/integrations/API-Wrappers/C%23/bin/VeracodeC%23API.zip" # Define a url de download
$caminhoDownload = "$env:LOCALAPPDATA/VeracodeAPI.zip" # Define um caminho para o arquivo de download
Invoke-WebRequest -Uri "$urlDownload" -OutFile "$caminhoDownload" # Faz o download
Expand-Archive -Path "$caminhoDownload" -DestinationPath "$pastaferramenta" -Force # Descompacta o ZIP para uma pasta
Rename-Item -Path "$pastaferramenta/VeracodeC#API.exe" -NewName "$pastaferramenta/VeracodeAPI.exe" -Force # Renomei para remover o # do nome
Remove-Item "$caminhoDownload" # Remove o arquivo de download

# Encerramento
Write-Host "Processo concluido"