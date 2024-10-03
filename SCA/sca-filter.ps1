# Fazer o scan e obter informações:
# Executar o SCA Agent-Based e gerar o json com os resultados
# Receber esse JSON e validar as bibliotecas listadas
# Validar as licenças
# Caso exista uma licença não permitida, bloquear

function Get-VeracodeScaLicenses {
    param (
        $scaResultados
    )
    $scaLibraries = $scaResultados.records.libraries
    foreach ($scaLibrarie in $scaLibraries) {
        $license = $scaLibrarie.versions.licenses
        $containsGPL = $license | Where-Object { $_.name -match "Affero" }
        if ($containsGPL) {
            $componentName = $scaLibrarie.name
            Write-Error "Foi encontrada a licenca AGPL no componente $componentName"
        }
    }
}

# Faz a validacao dos problemas criticos
function Get-VeracodeScaVulnerabilities {
    param (
        $scaResultados,
        $cvss3ScoreFilter = 9.0
    )
    $scaVulnerabilities = $scaResultados.records.vulnerabilities
    foreach ($scaVulnerabilitie in $scaVulnerabilities) {
        $cvss3Score = $scaVulnerabilitie.cvss3Score
        if ($cvss3Score -ge $cvss3ScoreFilter) {
            $title = $scaVulnerabilitie.title
            $overview = $scaVulnerabilitie.overview
            $cve = $scaVulnerabilitie.cve 
            #$disclosureDate = $scaVulnerabilitie.disclosureDate
            $updateToVersion = $scaVulnerabilitie.libraries.details.updateToVersion
            Write-Host "Problema: $title"
            Write-Host "CVE: $cve - Nota de risco: $cvss3Score"
            Write-Host "Recomendado migrar para a versao: $updateToVersion"
            Write-Host "$overview"
            Write-Host ""
        }
    }
}


# Exemplos
srcclr scan --url https://github.com/veracode/example-ruby --json sca-agent-results.json
$scaResultados = Get-Content -Path "sca-agent-results.json" -Raw | ConvertFrom-Json
Get-VeracodeScaLicenses $scaResultados
Get-VeracodeScaVulnerabilities $scaResultados