param (
        [parameter(position=0,Mandatory=$True)]
        $validadorNome,
        [parameter(position=1)]
        $pastaBackup = [Environment]::GetFolderPath("Desktop")
)

# Recebe a lista de todos os nomes e IDs
[xml]$listaPerfisApp = $(VeracodeAPI.exe -action GetAppList)
$nomesApps = $listaPerfisApp.applist.app.app_name
$idApps = $listaPerfisApp.applist.app.app_id

# Inicializa o indice
[int]$indice = 0

# Valida se existe algum nome com o prefixo
foreach ($nomeApp in $nomesApps) {
    if ($nomeApp -like "*$validadorNome*") {
        $appID = $idApps[$indice]
        [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildinfo -appid $appID)
        $buildID = $buildINFO.buildinfo.build_id

        # Faz o Backup
        VeracodeAPI.exe -action detailedreport -buildid "$buildID" -format pdf -outputfilepath "$pastaBackup\$nomeApp-$buildID.pdf"
    }
    $indice = $indice + 1
}