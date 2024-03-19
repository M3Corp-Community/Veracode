function Get-VeracodeHealth {
    $statusVeracode = curl "https://api.status.veracode.com/status" | ConvertFrom-Json
    $appServiceStatus = $statusVeracode.application_service.status

    if ($appServiceStatus -eq "UP") {
        Write-Host "Veracode Application Service -> OK"
    } else {
        throw "Error in Veracode Plataform"
    }
}
Get-VeracodeHealth