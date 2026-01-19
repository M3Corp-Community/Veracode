function Get-VeracodeScanData {

    Write-Host "[INFO] Criando relatório SCANS"

    $jsonData = @{
        "report_type" = "SCANS"
        "last_updated_start_date" = "2026-01-14 00:00:00"
    }

    $json = $jsonData | ConvertTo-Json

    $apiReturn = $json |
        http --auth-type=veracode_hmac POST `
        "https://api.veracode.com/appsec/v1/analytics/report" |
        ConvertFrom-Json

    $reportID = $apiReturn._embedded.id
    Write-Host "[INFO] Report ID: $reportID"

    # ===== Aguarda processamento =====
    $status = "PROCESSING"

    while ($status -eq "PROCESSING") {
        Write-Host "[INFO] Aguardando relatório..."
        Start-Sleep 10

        $VeracodeData = http --auth-type=veracode_hmac GET `
            "https://api.veracode.com/appsec/v1/analytics/report/$reportID" |
            ConvertFrom-Json

        $status = $VeracodeData._embedded.status
        Write-Host "[INFO] Status atual: $status"
    }

    Write-Host "[INFO] Relatório concluído"

    # ===== Paginação via HATEOAS =====

    $currentPageData = $VeracodeData
    $currentPage = $currentPageData.page_metadata.number
    $totalPages  = $currentPageData.page_metadata.total_pages

    Write-Host "[INFO] Página inicial: $currentPage / Total páginas: $totalPages"

    $totalScans = 0

    if ($currentPageData._embedded.scans) {
        $count = $currentPageData._embedded.scans.Count
        $totalScans += $count
        Write-Host "[INFO] Página $currentPage trouxe $count scans (Total acumulado: $totalScans)"
    }

    while ($currentPageData._embedded._links.next.href) {

        $nextHref = $currentPageData._embedded._links.next.href
        Write-Host "[INFO] Buscando próxima página: $nextHref"

        $currentPageData = http --auth-type=veracode_hmac GET `
            "https://api.veracode.com$nextHref" |
            ConvertFrom-Json

        $pageNumber = $currentPageData.page_metadata.number

        if ($currentPageData._embedded.scans) {
            $count = $currentPageData._embedded.scans.Count
            $totalScans += $count
            Write-Host "[INFO] Página $pageNumber trouxe $count scans (Total acumulado: $totalScans)"

            # Merge no objeto original (sem mudar retorno)
            $VeracodeData._embedded.scans += $currentPageData._embedded.scans
        } else {
            Write-Host "[WARN] Página $pageNumber não trouxe scans"
        }
    }

    Write-Host "[INFO] Paginação finalizada"
    Write-Host "[INFO] Total de scans consolidados: $totalScans"

    return $VeracodeData
}

function Get-CostOfRemediation {
    param (
        [Parameter(Mandatory)]
        $VeracodeData,

        [Parameter(Mandatory)]
        [int]$VulnerabilitiesFixed,

        [decimal]$MTTRHours = 6,

        [Parameter(Mandatory)]
        [array]$TeamComposition
    )

    $scans = $VeracodeData._embedded.scans

    # Scan mais recente por app (mesma lógica das outras funções)
    $latestScans =
        $scans |
        Group-Object app_id |
        ForEach-Object {
            $mostRecent = $_.Group | Where-Object { $_.most_recent_scan -eq $true }
            if ($mostRecent.Count -gt 0) {
                $mostRecent | Select-Object -First 1
            } else {
                $_.Group | Sort-Object published -Descending | Select-Object -First 1
            }
        }

    # Cálculo do custo/hora ponderado do time
    $weightedCostPerHour = 0
    foreach ($role in $TeamComposition) {
        $weightedCostPerHour += ($role.Percentage * $role.CostPerHour)
    }

    # Resultado por aplicação
    $latestScans | ForEach-Object {

        $remediationCost =
            $MTTRHours *
            $weightedCostPerHour *
            $VulnerabilitiesFixed

        [PSCustomObject]@{
            AppId                = $_.app_id
            AppName              = $_.app_name
            ScanId               = $_.scan_id
            ScanDate             = $_.published
            VulnerabilitiesFixed = $VulnerabilitiesFixed
            MTTRHours            = $MTTRHours
            WeightedCostPerHour  = [Math]::Round($weightedCostPerHour, 2)
            RemediationCost      = [Math]::Round($remediationCost, 2)
        }
    }
}

function Get-CostAvoided {
    param (
        [Parameter(Mandatory)]
        $VeracodeData,

        [decimal]$AverageIncidentCost = 5000000
    )

    $scans = $VeracodeData._embedded.scans

    # Scan mais recente por app
    $latestScans =
        $scans |
        Group-Object app_id |
        ForEach-Object {
            $mostRecent = $_.Group | Where-Object { $_.most_recent_scan -eq $true }
            if ($mostRecent.Count -gt 0) {
                $mostRecent | Select-Object -First 1
            } else {
                $_.Group | Sort-Object published -Descending | Select-Object -First 1
            }
        }

    # Resultado por aplicação
    $latestScans | ForEach-Object {

        $criticalHighCount = $_.num_s5_flaws + $_.num_s4_flaws
        $costAvoided = $criticalHighCount * $AverageIncidentCost

        [PSCustomObject]@{
            AppId                 = $_.app_id
            AppName               = $_.app_name
            ScanId                = $_.scan_id
            ScanDate              = $_.published
            CriticalHighFindings  = $criticalHighCount
            AverageIncidentCost   = $AverageIncidentCost
            EstimatedCostAvoided  = [Math]::Round($costAvoided, 2)
        }
    }
}

function Get-VulnerabilitiesFixed {
    param (
        [Parameter(Mandatory)]
        $Scan
    )

    $fixed = 0

    if ($Scan.num_fixed_flaws) {
        $fixed += [int]$Scan.num_fixed_flaws
    }

    if ($Scan.num_mitigated_flaws) {
        $fixed += [int]$Scan.num_mitigated_flaws
    }

    return $fixed
}

function Get-VeracodeRiskScore {
    param (
        [Parameter(Mandatory)]
        $VeracodeData,

        [hashtable]$Weights = @{
            VeryHigh      = 5
            High          = 4
            Medium        = 3
            Low           = 2
            VeryLow       = 1
            Informational = 0.5
        }
    )

    $scans = $VeracodeData._embedded.scans

    # Seleciona o scan mais recente por app
    $latestScans =
        $scans |
        Group-Object app_id |
        ForEach-Object {
            $mostRecent = $_.Group | Where-Object { $_.most_recent_scan -eq $true }
            if ($mostRecent.Count -gt 0) {
                $mostRecent | Select-Object -First 1
            } else {
                $_.Group | Sort-Object published -Descending | Select-Object -First 1
            }
        }

    # Calcula o Risk Score
    $latestScans | ForEach-Object {

        $riskScore =
            ($_.num_s5_flaws * $Weights.VeryHigh) +
            ($_.num_s4_flaws * $Weights.High) +
            ($_.num_s3_flaws * $Weights.Medium) +
            ($_.num_s2_flaws * $Weights.Low) +
            ($_.num_s1_flaws * $Weights.VeryLow) +
            ($_.num_s0_flaws * $Weights.Informational)

        [PSCustomObject]@{
            AppId     = $_.app_id
            AppName   = $_.app_name
            ScanId    = $_.scan_id
            ScanName  = $_.scan_name
            VeryHigh  = $_.num_s5_flaws
            High      = $_.num_s4_flaws
            Medium    = $_.num_s3_flaws
            Low       = $_.num_s2_flaws
            VeryLow   = $_.num_s1_flaws
            Info      = $_.num_s0_flaws
            RiskScore = [Math]::Round($riskScore, 2)
            ScanDate  = $_.published
        }
    }
}



# Testes
$VeracodeData = Get-VeracodeScanData
$TeamComposition = @(
    @{ Role = "Junior";   Percentage = 0.30; CostPerHour = 60  }
    @{ Role = "Mid";      Percentage = 0.40; CostPerHour = 90  }
    @{ Role = "Senior";   Percentage = 0.20; CostPerHour = 140 }
    @{ Role = "Lead";     Percentage = 0.10; CostPerHour = 180 }
)
$risk = Get-VeracodeRiskScore $VeracodeData
$remediation = Get-CostOfRemediation -VeracodeData $VeracodeData -VulnerabilitiesFixed 10 -MTTRHours 6 -TeamComposition $TeamComposition
$avoided = Get-CostAvoided -VeracodeData $VeracodeData -AverageIncidentCost 5000000
$risk | Format-Table AppName, ScanDate, RiskScore, VeryHigh, High, Medium -AutoSize
$remediation | Format-Table AppName, RemediationCost
$avoided | Format-Table AppName, EstimatedCostAvoided

# Excel:
$risk | Export-Csv risk.csv -NoTypeInformation
$remediation | Export-Csv remediation.csv -NoTypeInformation
$avoided | Export-Csv avoided.csv -NoTypeInformation

# GridView
$risk | Out-GridView -Title "Risk Score por Aplicação"
$remediation | Out-GridView -Title "Custo de Remediação"
$avoided | Out-GridView -Title "Custo Evitado Estimado"