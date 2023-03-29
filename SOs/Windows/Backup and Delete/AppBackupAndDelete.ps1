param (
    [parameter(position = 0)]
    $pastaBackup = [Environment]::GetFolderPath("Desktop")
)

# Configure o Wrapper na pasta abaixo
# Caso já tenha adicinado ela ao path do sistema, pode ignorar essa linha
$pastaferramenta = "$Env:Programfiles/Veracode/"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$pastaferramenta")

# Recebe a lista de todos os nomes e IDs
[xml]$listaPerfisApp = $(VeracodeAPI.exe -action GetAppList)
$nomesApps = $listaPerfisApp.applist.app.app_name
$idApps = $listaPerfisApp.applist.app.app_id

# Inicializa o indice
[int]$indice = 0

# Valida se existe algum nome com o prefixo
foreach ($nomeApp in $nomesApps) {
    $appID = $idApps[$indice]
    $numeroVersao = Get-Date -Format hhmmssddMMyy
    [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildinfo -appid $appID)
    $buildID = $buildINFO.buildinfo.build_id

    # Faz o Backup
    VeracodeAPI.exe -action detailedreport -buildid "$buildID" -format pdf -outputfilepath "$pastaBackup\$nomeApp-$numeroVersao.pdf"
    VeracodeAPI.exe -action thirdpartyreport -buildid "$buildID" -format pdf -outputfilepath "$pastaBackup\$nomeApp-SCA-$numeroVersao.pdf"

    # Deleta o perfil
    Write-Host "Removendo perfil: $nomeApp - $appID"
    [xml]$Status = VeracodeAPI.exe -action deleteapp -appid "$appID"

    # Faz a validacao
    $resultado = $status.deleteapp.result
    if ($resultado -eq "success") {
        Write-Host "O perfil $nomeApp foi removido com sucesso"
    }
    else {
        Write-Host "Erro ao deletar o perfil: $nomeApp"
        Write-Host $Status
    }
    $indice = $indice + 1
}