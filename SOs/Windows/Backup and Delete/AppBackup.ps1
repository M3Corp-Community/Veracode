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
    [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildinfo -appid $appID)
    $buildID = $buildINFO.buildinfo.build_id

    # Faz o Backup
    VeracodeAPI.exe -action detailedreport -buildid "$buildID" -format pdf -outputfilepath "$pastaBackup\$nomeApp-$buildID.pdf"
    VeracodeAPI.exe -action thirdpartyreport -buildid "$buildID" -format pdf -outputfilepath "$pastaBackup\$nomeApp-SCA-$buildID.pdf"
    $indice = $indice + 1
}