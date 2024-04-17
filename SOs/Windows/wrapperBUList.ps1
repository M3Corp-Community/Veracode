function Set-VeracodeBU {
    param (
        $veracodeAppName,
        $businessUnit
    )
    # Recebe o App ID com base no nome da aplicacao dentro do Veracode
    [xml]$INFO = $(java -jar veracode-wrapper.jar -action GetAppList | Select-String -Pattern $veracodeAppName)[0]
    # Filtra o App ID
    $appID = $INFO.app.app_id
    # Faz a modificação de BU
    Write-Host "Add $veracodeAppName (ID: $appID) in $businessUnit"
    java -jar veracode-wrapper.jar -action updateapp -appid $appID -businessunit "$businessUnit"
}

# Teste
$appProfilesList = $profilesInTeam.profile.name
foreach ($veracodeAppName in $appProfilesList) {
    Set-VeracodeBU "$veracodeAppName" "Legado"
    Start-Sleep 3
}