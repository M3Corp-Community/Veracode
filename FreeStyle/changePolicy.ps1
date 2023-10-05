function Get-VeracodeAppProfileID {
    param (
        $veracodeAppProfile
    )
    
    try {
        [xml]$INFO = $(VeracodeAPI.exe -action GetAppList | Select-String -Pattern $veracodeAppProfile)[0]
        $veracodeAppProfileID = $INFO.app.app_id
        return $veracodeAppProfileID
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Set-VeracodePolicy {
    param (
        $veracodeAppProfileID,
        $policyName
    )

    try {
        [xml]$changeReturn = $(VeracodeAPI.exe -action updateapp -appid "$veracodeAppProfileID" -criticality "VeryHigh" -policy "$policyName")
        $newAppPolicy = $changeReturn.appinfo.application.policy
        $dateChangePolicy = $changeReturn.appinfo.application.policy_updated_date
        Write-Host "New Policy: $newAppPolicy - Changed in: $dateChangePolicy"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Get-VeracodeCurrentAppPolicy {
    param (
        $veracodeAppProfileID
    )

    try {
        [xml]$INFO = $(VeracodeAPI.exe -action getappinfo -appid "$veracodeAppProfileID")
        $currentPolicy = $INFO.appinfo.application.policy
        return $currentPolicy
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Get-VeracodeAllAppProfiles {
    try {
        [xml]$INFO = $(VeracodeAPI.exe -action GetAppList)
        $appList = $INFO.applist.app.app_name
        return $appList
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

# For this case, I need a filter the Apps by the current policy and change it
$targetAppPolicy = "Veracode Recommended Very High + SCA"
$newAppPolicy = "Veracode Recommended POV"
$veracodeAllAppProfiles = Get-VeracodeAllAppProfiles
foreach ($veracodeAppProfile in $veracodeAllAppProfiles) {
    try {
        $veracodeAppProfileID = Get-VeracodeAppProfileID "$veracodeAppProfile"
        $currentPolicy = Get-VeracodeCurrentAppPolicy $veracodeAppProfileID
        if ($currentPolicy -eq $targetAppPolicy) {
            Write-Host "Veracode App Profile: $veracodeAppProfile - AppID: $veracodeAppProfileID"
            Write-Host "Current Policy: $currentPolicy"
            Write-Host "Updating Policy to $newAppPolicy"
            Set-VeracodePolicy $veracodeAppProfileID "$newAppPolicy"
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}