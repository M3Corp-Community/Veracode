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
        $jsonTribe = $jsonData | ConvertTo-Json
        $apiReturn = $jsonTribe | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/business_units"
        $apiReturn = $apiReturn | ConvertFrom-Json
        $tribeID = $apiReturn.bu_id
    }
    
    return $tribeID
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
        $squadID = $apiReturn.team_id
    }
    return $squadID
}

function Add-VeracodeSquadInTribe {
    param (
        $squadID,
        $tribeID
    )
    $jsonData = @{
        "teams" = @(
            @{
                "team_id" = "$squadID"
            }
        )
    }
    $jsonTeam = $jsonData | ConvertTo-Json
    $url = "https://api.veracode.com/api/authn/v2/business_units/" + $tribeID + "?partial=true&incremental=true"
    $apiReturn = $jsonTeam |http --auth-type=veracode_hmac PUT $url
    $apiReturn = $apiReturn | ConvertFrom-Json
    $nameTribo = $apiReturn.bu_name
    $infoSquad = $apiReturn.teams
    $nameTeam = ($infoSquad | Where-Object { $_.team_id -eq "$squadID" }).team_name
    $returnInfo = "$nameTribo : $nameTeam"
    return $returnInfo
}

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

function New-VeracodeTribesSquads {
    param (
        $caminhoJson
    )
    # Carrega as informacoes
    $tribeList = Get-VeracodeTribes
    $squadList = Get-VeracodeSquads
    $jsonInfo = Get-Content $caminhoJson | ConvertFrom-Json
    $jsonName = ($jsonInfo | Get-Member -MemberType Properties).name
    #$jsonInfo.$jsonName
    $triboName = $jsonName.Replace("dtl_", "")
    $tribeID = New-VeracodeTribe $triboName $tribeList
    Write-Host "$triboName : $tribeID"
    $jsonPositions = ($jsonInfo.$jsonName| Get-Member -MemberType Properties).name
    $squadWorkList = $jsonInfo.$jsonName.$jsonPositions
    foreach ($squad in $squadWorkList) {
        if ($null -ne $squad) {
            $squadName = $squad.Replace("dtl_po_", "")
            $dtlList = @("dtl_el_", "dtl_dev_")
            foreach ($dtl in $dtlList) {
                $squadDTL = $dtl + $squadName
                #Write-Host "Criando a DTL: $squadDTL - Tribo: $triboName"
                $squadID = New-VeracodeSquad $squadDTL $squadList
                #Write-Host "$squadDTL : $squadID"
                Add-VeracodeSquadInTribe $squadID $tribeID
                Start-Sleep 3
            }
            
        }
    }
}

# Test

# Obtém todos os arquivos JSON na pasta
$arquivosJSON = Get-ChildItem -Path . -Filter *.json

# Itera sobre cada arquivo JSON encontrado
foreach ($caminhoJson in $arquivosJSON) {
    New-VeracodeTribesSquads $caminhoJson
}