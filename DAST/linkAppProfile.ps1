function Get-VeracodeDastList {
    $allDASTs = http --auth-type=veracode_hmac GET "https://api.veracode.com/was/configservice/v1/analyses/?all_for_org=true&size=10000" | ConvertFrom-Json
    $dastList = $allDASTs._embedded.analyses
    return $dastList
}

function Get-VeracodeDastID {
    param (
        $dastName,
        $dastList
    )
    $dastID = ($dastList | Where-Object { $_.name -eq "$dastName" }).analysis_id
    return $dastID
}

function New-VeracodeAppProfile {
    param (
        $appName
    )
    $jsonData = @{
        profile = @{
            name = "$appName"
            business_criticality = "VERY_HIGH"
        }
    } | ConvertTo-Json
    $apiReturn = $jsonData | http --auth-type=veracode_hmac POST "https://api.veracode.com/appsec/v1/applications"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $appProfileID = $apiReturn.guid
    return $appProfileID
}

function Get-VeracodeAppProfiles {
    $infoApps = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=10000" | ConvertFrom-Json
    $appList = $infoApps._embedded.applications
    return $appList
}

function Get-VeracodeAppProfileID {
    param (
        $appName,
        $appList
    )
    $appProfileID = ($appList | Where-Object { $_.profile.name -eq "$appName" }).guid
    return $appProfileID
}

function New-VeracodeProfileLink {
    param (
        $dastID,
        $appProfileID
    )
    $jsonData = @{
        linked_platform_app_uuid = "$appProfileID"
    } | ConvertTo-Json
    $url = "https://api.veracode.com/was/configservice/v1/scans/" + $dastID + "?method=PATCH"
    $apiReturn = $jsonData | http --auth-type=veracode_hmac PUT $url
    $apiReturn = $apiReturn | ConvertFrom-Json
    return $apiReturn
}