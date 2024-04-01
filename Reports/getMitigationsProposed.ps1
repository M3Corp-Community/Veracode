function Get-VeracodeAllFlaws {
    $jsonData = @{
        "report_type"= "findings"
        "last_updated_start_date" = "2024-01-01 00:10:10"
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

function Get-VeracodeMitigationDetails {
    param (
        $mitigationList
    )
    foreach ($mitigation in $mitigationList) {
        # organiza as infos
        $appName = $mitigation.app_name
        $flaw_id = $mitigation.flaw_id
        $flaw_name = $mitigation.flaw_name
        $cwe_id = $mitigation.cwe_id
        $category_name = $mitigation.category_name
        $cwe_description = $mitigation.cwe_description
        $scan_type = $mitigation.scan_type
        $mitigation_last_proposed_date = $mitigation.mitigation_last_proposed_date
        $mitigation_last_proposed_comment = $mitigation.mitigation_last_proposed_comment
        $mitigation_last_proposed_username = $mitigation.mitigation_last_proposed_username
        $resolution = $mitigation.resolution

        # Publica
        Write-Host "$resolution - $appName - $scan_type"
        Write-Host "Flaw: $flaw_id - $flaw_name"
        Write-Host "$cwe_id - $category_name"
        Write-Host "$cwe_description"
        Write-Host "Proposto por: $mitigation_last_proposed_username - Em $mitigation_last_proposed_date"
        Write-Host "Justificativa: $mitigation_last_proposed_comment"
        Write-Host "..."
    }
}

$veracodeAllFlaws = Get-VeracodeAllFlaws
$mitigateProposedFlaws = Get-VeracodeAllMitigationProposed $veracodeAllFlaws
Get-VeracodeMitigationDetails $mitigateProposedFlaws