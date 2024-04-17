$squadDTL = ""
$triboName = ""

# Faz a instalacao do recurso da Veracode
pip install veracode-api-signing

function Get-VeracodeSquads {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.teams
    return $teamList
}

function Get-VeracodeTribes {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/business_units?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.business_units
    return $teamList
}

function New-VeracodeTribe {
    param (
        $tribeName,
        $tribeList
    )
    $jsonData = @{
        "bu_name" = "$tribeName"
    }
    $tribeID = ($tribeList | Where-Object { $_.bu_name -eq "$tribeName" }).bu_id
    if (-not $tribeID) {
        Write-Host "Criando tribo: $tribeName"
        $jsonTribe = $jsonData | ConvertTo-Json
        $apiReturn = $jsonTribe | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/business_units"
        $apiReturn = $apiReturn | ConvertFrom-Json
        $tribeName = $apiReturn.bu_name
        Write-Host "Criada a tribo: $tribeName"
    } else {
        Write-Host "Ja existe a tribo: $tribeName"
    }
}

function New-VeracodeSquad {
    param (
        $squadName,
        $squadList
    )
    $jsonData = @{
        "team_name" = "$squadName"
    }
    $squadID = ($squadList | Where-Object { $_.team_name -eq "$squadName" }).team_id
    if (-not $squadID) {
        $jsonTeam = $jsonData | ConvertTo-Json
        $apiReturn = $jsonTeam | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/teams"
        $apiReturn = $apiReturn | ConvertFrom-Json
        $squadName = $apiReturn.team_Name
        Write-Host "Criada a squad: $squadName"
    } else {
        Write-Host "Ja existe a squad: $tribeName"
    }
}

# Recebe a lista dos que existem
$allTribes = Get-VeracodeTribes
$allSquads = Get-VeracodeSquads

# Faz a validacao das squads
$squadList = $squadDTL.Split(',')
foreach ($squadName in $squadList) {
    New-VeracodeSquad "$squadName" $allSquads
}

# Faz a validacao das tribos
New-VeracodeTribe "$triboName" $allTribes