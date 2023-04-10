param (
    $veracodeAppName
)

try {
    # Recebe os detalhes do perfil de App
    $infosApp = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name=$veracodeAppName" | ConvertFrom-Json
    $guidApp = $infosApp._embedded.applications.guid

    # Recebe os scans DAST
    $resultados = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$guidApp/findings?scan_type=SCA" | ConvertFrom-Json
    $falhasDAST = $resultados._embedded.findings

    # Valida se existe alguma falha que viola a politica
    $totalFalhas = $falhasDAST.count
    if ($totalFalhas -gt 0) {
        Write-Host "Foram encontradas falhas nesse scan"
        $falhasDAST
        Write-Error -Message "Total de Falhas: $totalFalhas" -Category SecurityError
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "$ErrorMessage"
}