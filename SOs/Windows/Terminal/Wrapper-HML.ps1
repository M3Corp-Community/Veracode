# Configuracoes
$nomeProjeto = ""
$caminhoPastaProjeto = ""
$siglaAmbiente = "HML"

# Função para executar um SAST
function New-SAST {
    param (
        [parameter(position=0,Mandatory=$True)]
        $AppProfile,
        [parameter(position=1,Mandatory=$True)]
        $caminhoArquivo,
        [parameter(position=2,Mandatory=$True)]
        $siglaAmbiente
    )
    # Configuracoes
    $numeroVersao = Get-Date -Format hhmmssddMMyy # Cria um hash com base no dia e hora para numero de versão
    # Faz o scan
    VeracodeAPI.exe -action UploadAndScan -appname "$AppProfile" -createprofile true -sandboxname "$siglaAmbiente" -createsandbox true  -filepath "$caminhoArquivo" -version $numeroVersao
}

# Faz o zip dos arquivos
Compress-Archive -Path $caminhoPastaProjeto -DestinationPath veracode.zip -Force

# Faz o SAST sem aguardar
New-SAST $nomeProjeto veracode.zip $siglaAmbiente