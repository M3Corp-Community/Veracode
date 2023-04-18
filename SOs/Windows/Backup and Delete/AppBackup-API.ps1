param (
    $veracodeAppName
)

try {
    # Recebe os detalhes do perfil de App
    $infosApp = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name=$veracodeAppName" | ConvertFrom-Json
    $guidApp = $infosApp._embedded.applications.guid

    # Recebe os scans SCA
    $resultados = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$guidApp/findings?scan_type=SCA" | ConvertFrom-Json
    $falhasDAST = $resultados._embedded.findings

}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "$ErrorMessage"
}