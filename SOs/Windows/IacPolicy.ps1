function New-VeracodeRepoScan {
    param (
        $urlRepo
    )
    $json = veracode scan --type repo --source "$urlRepo" | ConvertFrom-Json
    $policy = $json.'policy-passed'
    if ($policy -eq $false) {
        $problemsList = $json.'policy-results'.failures.msg
        foreach ($problem in $problemsList) {
            Write-Host "$problem"
        }
        Write-Error "Policy dont Pass"
    } else {
        Write-Host "Policy Pass"
    }
}

# This function is for Linux
function New-VeracodeDirectoryScan {
    param (
        $folderPath
    )
    Set-Location $folderPath
    $json = ./veracode scan --type directory --source . | ConvertFrom-Json
    $policy = $json.'policy-passed'
    if ($policy -eq $false) {
        $problemsList = $json.'policy-results'.failures.msg
        foreach ($problem in $problemsList) {
            Write-Host "$problem"
        }
        Write-Error "Policy dont Pass"
    } else {
        Write-Host "Policy Pass"
    }
}

New-VeracodeRepoScan "https://github.com/IGDEXE/Terragoat"