param (
    [parameter(position=0)]
    $nomeProjeto,
    [parameter(position=1)]
    $caminhoPastaProjeto
)

# Variavel de ambiente (recomendo deixar salva no Path)
$Env:SRCCLR_API_TOKEN = ""

# Faz o download do script
iex ((New-Object System.Net.WebClient).DownloadString('https://download.srcclr.com/ci.ps1'))

# Faz o scan
srcclr scan --update-advisor --allow-dirty