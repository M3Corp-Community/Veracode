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

function Get-VeracodeBuildID {
    param (
        $veracodeAppProfileID
    )
    try {
        [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildinfo -appid $veracodeAppProfileID)
        $VeracodeBuildID = $buildINFO.buildinfo.build_id
        return $VeracodeBuildID
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function New-VeracodeSummaryReport {
    param (
        $veracodeAppProfile,
        $VeracodeBuildID,
        $reportFolder
    )

    try {
        $reportName = "$veracodeAppProfile-Summary-$VeracodeBuildID.pdf"
        VeracodeAPI.exe -action summaryreport -buildid "$VeracodeBuildID" -format pdf -outputfilepath "$reportFolder\$reportName"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function New-VeracodeDetailedReport {
    param (
        $veracodeAppProfile,
        $VeracodeBuildID,
        $reportFolder
    )

    try {
        $reportName = "$veracodeAppProfile-Detailed-$VeracodeBuildID.pdf"
        VeracodeAPI.exe -action detailedreport -buildid "$VeracodeBuildID" -format pdf -outputfilepath "$reportFolder\$reportName"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

# Generate Report for all Policy Scan
$reportFolder = "$env:LOCALAPPDATA"
$veracodeAllAppProfiles = Get-VeracodeAllAppProfiles
foreach ($veracodeAppProfile in $veracodeAllAppProfiles) {
    try {
        Write-Host "App Profile: $veracodeAppProfile"
        $veracodeAppProfileID = Get-VeracodeAppProfileID "$veracodeAppProfile"
        $VeracodeBuildID = Get-VeracodeBuildID $veracodeAppProfileID
        # Policy Scan Reports
        New-VeracodeSummaryReport $veracodeAppProfile $VeracodeBuildID $reportFolder
        New-VeracodeDetailedReport $veracodeAppProfile $VeracodeBuildID $reportFolder
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}