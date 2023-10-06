function Get-VeracodeAppProfileID {
    param (
        $veracodeAppProfile
    )
    
    try {
        [xml]$INFO = $(VeracodeAPI.exe -action GetAppList | Select-String -Pattern "$veracodeAppProfile")[0]
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

function Get-VeracodeSandBoxID {
    param (
        $veracodeSandBoxName,
        $veracodeSBList
    )
    try {
        $VeracodeSandBoxID = ($veracodeSBList | Where-Object { $_.sandbox_name -eq "$veracodeSandBoxName" }).sandbox_id
        if ($VeracodeSandBoxID) {
            return $VeracodeSandBoxID
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Get-VeracodeBuildID {
    param (
        $veracodeAppProfileID,
        $veracodeSandBoxID
    )
    try {
        [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildlist -appid $veracodeAppProfileID -sandboxid $veracodeSandBoxID)
        $VeracodeBuildList = $buildINFO.buildlist.build.build_id
        $buildCount = $VeracodeBuildList.count
        if ($buildCount -gt 1) {
            [array]::Reverse($VeracodeBuildList)
            $VeracodeBuildID = $VeracodeBuildList[0]
        } else {
            $VeracodeBuildID = $VeracodeBuildList
        }
        return $VeracodeBuildID
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function New-VeracodeSummaryReportSB {
    param (
        $veracodeAppProfile,
        $veracodeSandBoxName,
        $VeracodeBuildID,
        $reportFolder
    )

    try {
        $reportName = "$veracodeAppProfile-$veracodeSandBoxName-Summary-$VeracodeBuildID.pdf"
        VeracodeAPI.exe -action summaryreport -buildid "$VeracodeBuildID" -format pdf -outputfilepath "$reportFolder\$reportName"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function New-VeracodeDetailedReportSB {
    param (
        $veracodeAppProfile,
        $veracodeSandBoxName,
        $VeracodeBuildID,
        $reportFolder
    )

    try {
        $reportName = "$veracodeAppProfile-$veracodeSandBoxName-Detailed-$VeracodeBuildID.pdf"
        VeracodeAPI.exe -action detailedreport -buildid "$VeracodeBuildID" -format pdf -outputfilepath "$reportFolder\$reportName"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Get-VeracodeSandBoxList {
    param (
        $veracodeAppProfileID
    )
    try {
        [xml]$SBINFO = $(VeracodeAPI.exe -action getsandboxlist -appid $veracodeAppProfileID)
        $veracodeSBList = $SBINFO.sandboxlist.sandbox
        if ($veracodeSBList) {
            return $veracodeSBList
        } else {
            Write-Host "No Sandboxs in this profile"
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

function Set-CleanName {
    param (
        $CleanName
    )
    try {
        $CleanName = $CleanName.Replace("/", "")
        $CleanName = $CleanName.Replace("\", "")
        return $CleanName
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}

# Generate Report for all SandBoxs Scan
$reportFolder = "$env:LOCALAPPDATA"
$veracodeAllAppProfiles = Get-VeracodeAllAppProfiles
foreach ($veracodeAppProfile in $veracodeAllAppProfiles) {
    try {
        Write-Host "App Profile: $veracodeAppProfile"
        $veracodeAppProfileID = Get-VeracodeAppProfileID "$veracodeAppProfile"
        $veracodeSBList = Get-VeracodeSandBoxList $veracodeAppProfileID
        if ($veracodeSBList -ne "No Sandboxs in this profile") {
            foreach ($veracodeSB in $veracodeSBList) {
                $veracodeSandBoxName = $veracodeSB.sandbox_name
                $VeracodeSandBoxID = Get-VeracodeSandBoxID $veracodeSandBoxName $veracodeSBList
                $VeracodeBuildID = Get-VeracodeBuildID $veracodeAppProfileID $veracodeSandBoxID
                # SB Reports
                $veracodeSandBoxName = Set-CleanName $veracodeSandBoxName
                $veracodeAppProfile = Set-CleanName $veracodeAppProfile
                Write-Host "SB: $veracodeSandBoxName - ID: $VeracodeSandBoxID/$VeracodeBuildID"
                New-VeracodeSummaryReportSB $veracodeAppProfile $veracodeSandBoxName $VeracodeBuildID $reportFolder
                New-VeracodeDetailedReportSB $veracodeAppProfile $veracodeSandBoxName $VeracodeBuildID $reportFolder
            }
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage"
    }
}