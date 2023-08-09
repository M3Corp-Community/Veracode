try {
    $env:SRCCLR_SCM_URI='$(Build.Repository.Uri)'
    $env:SRCCLR_SCM_REF='$(Build.SourceBranchName)'
    $env:SRCCLR_SCM_REF_TYPE='branch'
    $env:SRCCLR_SCM_REV='$(Build.SourceVersion)'
    Set-ExecutionPolicy AllSigned -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://download.sourceclear.com/ci.ps1'))
    srcclr scan
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "$ErrorMessage"
}