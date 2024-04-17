$veracodeAppName = "$(veracodeAppName)"
$waitSeconds = 10 

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

# Verifica se o App Profile existe
$appInfo = Get-VeracodeAppDetails $veracodeAppName
$appID = $appInfo._embedded.applications.guid

if ($appID) {
    # Faz o loop de validacao
    while ($scanStatus -ne "PUBLISHEDk") {
        $appInfo = Get-VeracodeAppDetails $veracodeAppName
        $scanStatus = $appInfo._embedded.applications.scans.status
        Write-Host "Status atual do scan: $scanStatus"
        Write-Host "Aguardando $waitSeconds segundos ate a proxima validacao"
        Start-Sleep -Seconds $waitSeconds
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
} else {
    Write-Host "Nao foi encontrado o perfil $veracodeAppName"
}
