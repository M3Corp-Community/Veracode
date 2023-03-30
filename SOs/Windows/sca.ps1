param (
    [parameter(position=0)]
    $nomeProjeto = 35112835300323,
    [parameter(position=1)]
    $caminhoPastaProjeto = 35112835300323
)

# Variavel de ambiente (recomendo deixar salva no Path)
$Env:SRCCLR_API_TOKEN = ""

# Faz o download do script
iex ((New-Object System.Net.WebClient).DownloadString('https://download.srcclr.com/ci.ps1'))

# Verifica se foi informado um nome para o projeto
if ($nomeProjeto -ne "35112835300323") {
    Write-Host "Definindo nome do projeto: $nomeProjeto"
    $Env:SRCCLR_SCM_NAME = $nomeProjeto
}

# Verifica se foi informada uma pasta para o projeto
$pastaAtual = Get-Location
if ($caminhoPastaProjeto -ne "35112835300323") {
    Write-Host "Definindo pasta do projeto: $caminhoPastaProjeto"
    Set-Location -Path "$caminhoPastaProjeto"
}

# Faz o scan
srcclr scan --update-advisor --allow-dirty
Set-Location -Path "$pastaAtual"