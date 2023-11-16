param (
    [parameter(position=0)]
    $listURLsPath = "$env:LOCALAPPDATA\URL-List.txt",
    [parameter(position=1)]
    $Env:SRCCLR_API_TOKEN
)

function New-ScaAgentBasedScan {
    param (
        [parameter(position=0)]
        $projectURL = "https://github.com/M3Corp-Community/Verademo",
        [parameter(position=1)]
        $logFolderPath = "$env:LOCALAPPDATA"
    )

    # Configura o LOG
    $baseUrl = "https://github.com/M3Corp-Community/"
    $projectName = $projectURL.Replace($baseUrl, "")
    $timeStamp = Get-Date -Format hhmmssddMMyy
    $logPath = "$logFolderPath\sca-$projectName-$timeStamp.txt"
    Start-Transcript -Path "$logPath" -NoClobber
    
    try {
        # Start Scan
        srcclr scan --url "$projectURL"
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "$ErrorMessage"
    }
    Stop-Transcript
}

# Download SCA
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://download.srcclr.com/ci.ps1'))

$listURLs = Get-Content -Path "$listURLsPath"
foreach ($URL in $listURLs) {
    New-ScaAgentBasedScan $URL
}