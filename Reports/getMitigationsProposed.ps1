function Get-VeracodeAllFlaws {
    $jsonData = @{
        "report_type"= "findings"
        "last_updated_start_date" = "2024-01-01 00:10:10"
        "mitigation_status" = "Mitigation Proposed"
    }
    $json = $jsonData | ConvertTo-Json
    $apiReturn = $json | http --auth-type=veracode_hmac POST "https://api.veracode.com/appsec/v1/analytics/report"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $reportID = $apiReturn._embedded.id
    $status = "PROCESSING"
    while ($status -eq "PROCESSING") {
        if ($status -ne "PROCESSING") {
            Write-Host "Relatorio concluido"
        } else {
            Write-Host "Aguardando Relatorio.."
            Start-Sleep 10
            $veracodeAllFlaws = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/analytics/report/$reportID" | ConvertFrom-Json
            $status = $veracodeAllFlaws._embedded.status
        }
    }
    return $veracodeAllFlaws
}

function Get-VeracodeAllMitigationProposed {
    param (
        $apiReturn
    )
    $findings = $apiReturn._embedded.findings
    $mitigateProposed = $findings | Where-Object { $_.mitigation_status -eq "Mitigation Proposed" }
    return $mitigateProposed
}

$veracodeAllFlaws = Get-VeracodeAllFlaws
$mitigateProposedFlaws = Get-VeracodeAllMitigationProposed $veracodeAllFlaws
$mitigateProposedFlaws