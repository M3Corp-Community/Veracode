# Fazer o scan e obter informações:
# Executar o SCA Agent-Based e gerar o json com os resultados
# Receber esse JSON e validar as bibliotecas listadas
# Validar as licenças
# Caso exista uma licença não permitida, bloquear
srcclr scan --url https://github.com/veracode/example-ruby --json sca-agent-results.json
$scaResultados = Get-Content -Path "sca-agent-results.json" -Raw | ConvertFrom-Json
$scaLibraries = $scaResultados.records.libraries
foreach ($scaLibrarie in $scaLibraries) {
    $license = $scaLibrarie.versions.licenses
    $containsGPL = $license | Where-Object { $_.name -match "GPL" }
    if ($containsGPL) {
        $componentName = $scaLibrarie.name
        Write-Host "Foi encontrada a licenca GPL no componente $componentName"
    }
}

# Faz a validacao dos problemas criticos
$scaVulnerabilities = $scaResultados.records.vulnerabilities
foreach ($scaVulnerabilitie in $scaVulnerabilities) {
    $cvss3Score = $scaVulnerabilitie.cvss3Score
    if ($cvss3Score -ge 9.0) {
        $title = $scaVulnerabilitie.title
        $overview = $scaVulnerabilitie.overview
        $cve = $scaVulnerabilitie.cve 
        $disclosureDate = $scaVulnerabilitie.disclosureDate
        $updateToVersion = $scaVulnerabilitie.libraries.details.updateToVersion
        Write-Host "Problema: $title"
        Write-Host "CVE: $cve - Descoberto em: $disclosureDate"
        Write-Host "Recomendado migrar para a versao: $updateToVersion"
        Write-Host "$overview"
        Write-Host ""
    }
}
