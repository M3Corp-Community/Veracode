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
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$veracodeGuid/findings?scan_type=SCA&page=$pageNumber&size=500" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$veracodeGuid/findings?scan_type=SCA&page=$pageNumber&size=500" | ConvertFrom-Json
        $reportSCA += $apiReturn._embedded.findings
        # Incrementar o contador
        $pageNumber++
    }
    return $reportSCA
}

function Show-VeracodeScaResults {
    param (
        $scaResults
    )

    foreach ($scaResult in $scaResults) {
        $violates_policy = $scaResult.violates_policy
        $description = $scaResult.description
        $component_filename = $scaResult.finding_details.component_filename
        $version = $scaResult.finding_details.version
        $licenses = $scaResult.finding_details.licenses
        $component_path = $scaResult.finding_details.component_path.path
        Write-Host "$component_filename - $version"
        Write-Host "Fora de compliance? $violates_policy"
        Write-Host "$description"
        Write-Host "Licenciamento:"
        foreach ($license in $licenses) {
            $licenseID = $license.license_id
            $licenseRisk = $license.risk_rating
            Write-Host "$licenseID - $licenseRisk"
        }
        Write-Host "$licenses"
        Write-Host "Component Path:"
        foreach ($component in $component_path) {
            Write-Host "$component"
        }
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
