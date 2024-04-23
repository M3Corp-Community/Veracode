function Get-VeracodeAppProfiles {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=500" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=$pageNumber&size=500" | ConvertFrom-Json
        $appProfiles += $apiReturn._embedded.applications
        # Incrementar o contador
        $pageNumber++
    }
    return $appProfiles
}

function Get-VeracodeSCAResults {
    param (
        $veracodeGuid
    )
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$veracodeGuid/summary_report" | ConvertFrom-Json
    $reportSCA = $apiReturn.software_composition_analysis.vulnerable_components.component_dto
    return $reportSCA
}

function Show-VeracodeScaResults {
    param (
        $scaResults
    )

    foreach ($scaResult in $scaResults) {
        # General Info
        $violates_policy = $scaResult.component_affects_policy_compliance
        $component_filename = $scaResult.library
        $version = $scaResult.version
        # License info
        $licenses = $scaResult.licenses.license_dto
        $licenseName = $licenses.name
        $licenseRisk = $licenses.risk_rating
        # Show info
        Write-Host "$component_filename - $version"
        Write-Host "Fora de compliance? $violates_policy"
        Write-Host "Licenciamento: $licenseName - Risco: $licenseRisk"
        Write-Host "---"
    }
}

function Get-VeracodeAppProfile {
    param (
        $appName,
        $allProfiles
    )
    $profileInfo = $allProfiles | Where-Object { $_.profile.name -eq "$appName" }
    return $profileInfo
}

# Teste
$allProfiles = Get-VeracodeAppProfiles
foreach ($profile in $allProfiles) {
    $appName = $profile.profile.name
    $veracodeGuid = $profile.guid
    Write-Host "$appName - $veracodeGuid"
    $scaResults = Get-VeracodeSCAResults $veracodeGuid
    Show-VeracodeScaResults $scaResults
    Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    Start-Sleep 5
}