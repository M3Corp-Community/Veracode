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

function Get-VeracodeProfilesInTeam {
    param (
        $teamName,
        $profileList
    )
    $profilesInTeam = $profileList | Where-Object { $_.profile.teams.team_name -eq "$teamName" }
    return $profilesInTeam
}

function Get-VeracodeProfilesInBU {
    param (
        $buName,
        $profileList
    )
    $profilesInBU = $profileList | Where-Object { $_.profile.business_unit.name -eq "$buName" }
    return $profilesInBU
}

function Show-VeracodeAppBU {
    param (
        $profileList
    )
    foreach ($profile in $profileList) {
        $name = $profile.profile.name
        $BU = $profile.profile.business_unit.name
        Write-Host "$name - $BU"
    } 
}

function Get-VeracodeBUs {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/business_units?all_for_org=true&size=10000" | ConvertFrom-Json
    $buList = $apiReturn._embedded.business_units
    return $buList
}

function Get-VeracodeBuID {
    param (
        $buName,
        $buList
    )
    $buID = ($buList | Where-Object { $_.bu_name -eq "$buName" }).bu_id
    return $buID
}

function Get-VeracodeSCAResults {
    param (
        $veracodeGuid
    )
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$veracodeGuid/findings?scan_type=SCA" | ConvertFrom-Json
    $reportSCA = $apiReturn._embedded.findings
    return $reportSCA
}

# Teste
$allProfiles = Get-VeracodeAppProfiles
$profilesInTeam = Get-VeracodeProfilesInTeam "Localiza" $allProfiles
$profilesInBU = Get-VeracodeProfilesInBU "Not Specified" $allProfiles
Show-VeracodeAppBU $profilesInTeam
$allBUs = Get-VeracodeBUs
$buID = Get-VeracodeBuID "Localiza" $allBUs

$profilesInBU = Get-VeracodeProfilesInBU "Not Specified" $allProfiles
$profilesInTeam = Get-VeracodeProfilesInTeam "Localiza" $profilesInBU