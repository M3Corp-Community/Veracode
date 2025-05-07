function Get-VeracodeAllApps {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=500" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=$pageNumber&size=500" | ConvertFrom-Json
        $appProfiles += $apiReturn._embedded.applications
        # Incrementar o contador
        $pageNumber++
    }
    return $appProfiles
}

function Get-VeracodeAppGUID {
    param (
        $appName,
        $appProfiles
    )
    $appINFO = $appProfiles | Where-Object { $_.profile.name -eq "$appName" }
    $appGUID = $appINFO.guid
    return $appGUID
}

function Get-VeracodeAppFindings {
    param (
        $appGUID
    )
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$appGUID/findings?scan_type=STATIC" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$appGUID/findings?scan_type=STATIC&page=$pageNumber&size=500" | ConvertFrom-Json
        $appFindings += $apiReturn._embedded.findings
        # Incrementar o contador
        $pageNumber++
    }
    return $appFindings
}

function Get-VeracodeAppMitigatedFlaws {
    param (
        $appFindings
    )
    $appMitigatedFlaws = $appFindings | Where-Object { $_.finding_status.resolution -eq "MITIGATED" }
    return $appMitigatedFlaws
}

function New-VeracodeBaseline {
    param (
        $appMitigatedFlaws,  # Findings mitigados da aplicação
        $oldBaseline         # JSON base original
    )

    # Clonar o JSON original (exceto os findings)
    $newBaseline = @{
        _links        = $oldBaseline._links
        scan_id      = $oldBaseline.scan_id
        scan_status  = $oldBaseline.scan_status
        message      = $oldBaseline.message
        modules      = $oldBaseline.modules
        modules_count = $oldBaseline.modules_count
        findings     = @()
    }

    $uniqueFindings = @{}

    $sampleFinding = $oldBaseline.findings | Select-Object -First 1
    if ($sampleFinding) {
        $basePrefix = $sampleFinding.files.source_file.file -replace "/.*", ""
    } else {
        $basePrefix = ""
    }

    foreach ($mitigatedFlaw in $appMitigatedFlaws) {
        # Captura os campos relevantes
        $filePath = $mitigatedFlaw.finding_details.file_path
        $filePath = "$basePrefix/" + $filePath
        $lineNumber = $mitigatedFlaw.finding_details.file_line_number
        $attackVector = $mitigatedFlaw.finding_details.attack_vector
        $qualifiedFunctionName = $mitigatedFlaw.finding_details.procedure

        # Criar uma chave única
        $key = "$filePath|$lineNumber|$attackVector|$qualifiedFunctionName"

        # Se a chave ainda não existir, adicionar ao novo baseline
        if (-not $uniqueFindings.ContainsKey($key)) {
            $uniqueFindings[$key] = $mitigatedFlaw
            $newBaseline.findings += $mitigatedFlaw
        }
    }

    # Retornar o JSON formatado corretamente
    return $newBaseline | ConvertTo-Json -Depth 10
}
function Clear-VeracodeMitigatedFlaws {
    param (
        $appMitigatedFlaws,
        $pipelineResults
    )

    $filterResults = @()

    $sampleFinding = $pipelineResults.findings[0].files.source_file.file
    $basePrefix = ($sampleFinding -split '/')[0]

    $allFlaws = $pipelineResults.findings
    foreach ($flaw in $allFlaws) {
        # Valores da falha atual
        $FLAWfilePath = $flaw.files.source_file.file
        $FLAWlineNumber = $flaw.files.source_file.line
        $FLAWqualifiedFunctionName = $flaw.files.source_file.qualified_function_name

        # Use uma flag para determinar se a falha já foi removida
        $isMitigated = $false

        foreach ($mitigatedFlaw in $appMitigatedFlaws) {
            # Captura os valores que devem ser filtrados
            $filePath = $mitigatedFlaw.finding_details.file_path
            $filePath = "$basePrefix/" + "$filePath"
            $lineNumber = $mitigatedFlaw.finding_details.file_line_number
            $qualifiedFunctionName = $mitigatedFlaw.finding_details.procedure

            # Remove findings que correspondem aos valores mitigados
            if ($FLAWfilePath -eq $filePath -and $FLAWlineNumber -eq $lineNumber -and $FLAWqualifiedFunctionName -eq $qualifiedFunctionName) {
                # Marca como mitigada e sai do loop
                $isMitigated = $true
                break
            }
        }

        # Adiciona a falha se não foi mitigada
        if (-not $isMitigated) {
            $filterResults += $flaw
        }
    }
    return $filterResults
}

function Show-VeracodeFlaws {
    param (
        $filterResults
    )
    foreach ($result in $filterResults) {
        # Recebe os valores
        $issue_id = $result.issue_id
        $severity = $result.severity
        $issue_type = $result.issue_type
        $cwe_id = $result.cwe_id
        $display_text = $result.display_text
        $display_text = $display_text -replace '<span>', '' -replace '</span>', ''
        $file = $result.files.source_file.file
        $line = $result.files.source_file.line
        $function_name = $result.files.source_file.function_name
        $helpLink = $result.flaw_details_link

        # Exibe
        Write-Host "ID: $issue_id - Severidade: $severity"
        Write-Host "CWE ID: $cwe_id - CWE: $issue_type"
        Write-Host "Function: $function_name - Local: $file/$line"
        Write-Host "$display_text"
        Write-Host "Apoio adicional: $helpLink"
        Write-Host "  "
    }

    # Faz a validacao se existem erros
    $flawCount = $filterResults.count
    if ($flawCount -gt 0) {
        Write-Error "Existem $flawCount impactando a politica"
    }
}

# Fluxo:
# $appProfiles = Get-VeracodeAllApps
# $appGUID = Get-VeracodeAppGUID "$appProfile" $appProfiles
# $appFindings = Get-VeracodeAppFindings $appGUID
# $appMitigatedFlaws = Get-VeracodeAppMitigatedFlaws $appFindings
# $pipelineResults = Get-Content "filtered_results.json" | ConvertFrom-Json
# $filterResults = Clear-VeracodeMitigatedFlaws $appMitigatedFlaws $pipelineResults
# Show-VeracodeFlaws $filterResults