$veracodeAppName = "NodeGoat-Js-AzTG-v2"
pip install veracode-api-signing
function Get-VeracodeAppDetails {
    param (
        $veracodeAppName
    )
    $appInfo = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name=$veracodeAppName" | ConvertFrom-Json
    return $appInfo
}

function Get-VeracodeFindingsPanel {
    param (
        $findings
    )
    foreach ($finding in $findings) {
        $severity = $finding.finding_details.severity
        $file_path = $finding.finding_details.file_path
        $file_line_number = $finding.finding_details.file_line_number
        $cwe = $finding.finding_details.cwe.name
        $description = $finding.description
        
        # Exibe os resultados
        Write-Host "Severidade: $severity - Tipo: $cwe"
        Write-Host "Onde: $file_path - Linha: $file_line_number"
        Write-Host "Descricao:"
        Write-Host "$description"
        Write-Host "    "
    }
}

# Faz o loop de validacao
while ($scanStatus -ne "PUBLISHED") {
    $appInfo = Get-VeracodeAppDetails $veracodeAppName
    $scanStatus = $appInfo._embedded.applications.scans.status
    Write-Host "Status atual do scan: $scanStatus"
    Start-Sleep -Seconds 5
}

# Pega as informacoes do outro scans
$appGuid = $appInfo._embedded.applications.guid
$results = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$appGuid/findings?violates_policy=TRUE&size=10000" | ConvertFrom-Json
$findings = $results._embedded.findings
$findingsCount = $findings.count
if ($findingsCount -ne 0) {
    Get-VeracodeFindingsPanel $findings
    Write-Error "Foram encontrados $findingsCount apontamentos"
}