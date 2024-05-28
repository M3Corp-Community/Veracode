$veracodeAppName = ""
# Recebe o App ID com base no nome da aplicacao dentro do Veracode
[xml]$allApps = java -jar veracode-wrapper.jar -vid $(VERACODE_API_KEY_ID) -vkey $(VERACODE_API_KEY_SECRET) -action GetAppList
$appList = $allApps.appList.app
$appID = ($appList | Where-Object { $_.app_name -eq "$veracodeAppName" }).app_id
# Valida se existe um App ID
if ($appID) {
    [xml]$buildInfo = $(java -jar veracode-wrapper.jar -vid $(VERACODE_API_KEY_ID) -vkey $(VERACODE_API_KEY_SECRET) -action getbuildinfo -appid $appID)
    $resultsStatus = $buildInfo.buildinfo.build.analysis_unit.status
    if ($resultsStatus) {
        if ($resultsStatus -eq "Scan in Process") {
            Write-Host "O perfil $veracodeAppName tem um scan em andamento"
        } else {
            Write-Host "O perfil $veracodeAppName esta pronto para novos scans"
        }
    } else {
        Write-Host "Não foram encontradas analises para o projeto: $veracodeAppName"
    }
    
} else {
    Write-Host "Não foram encontradas informacoes para o projeto: $veracodeAppName"
}