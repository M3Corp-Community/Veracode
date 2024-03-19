function New-VeracodeTribe {
    param (
        $tribeName
    )
    $jsonData = @{
        "bu_name" = "$tribeName"
    }
    $jsonTribe = $jsonData | ConvertTo-Json
    $apiReturn = $jsonTribe | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/business_units"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $triboID = $apiReturn.bu_id
    return $triboID
}

function New-VeracodeSquad {
    param (
        $teamName
    )
    $jsonData = @{
        "team_name" = "$teamName"
    }
    $jsonTeam = $jsonData | ConvertTo-Json
    $apiReturn = $jsonTeam | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/teams"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $teamID = $apiReturn.team_id
    return $teamID
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
    $nameTeam = $apiReturn.teams.team_name
    $returnInfo = "$nameTribo : $nameTeam"
    return $returnInfo
}

function New-VeracodeTribesSquads {
    param (
        $caminhoJson
    )
    $jsonInfo = Get-Content $caminhoJson | ConvertFrom-Json
    $jsonName = ($jsonInfo | Get-Member -MemberType Properties).name
    $jsonInfo.$jsonName
    $triboName = $jsonName.Replace("YYY_", "")
    $tribeID = New-VeracodeTribo $triboName
    $jsonPositions = ($jsonInfo.$jsonName| Get-Member -MemberType Properties).name
    $squadList = $jsonInfo.$jsonName.$jsonPositions
    foreach ($squad in $squadList) {
        if ($null -ne $squad) {
            $squadName = $squad.Replace("YYY_XX_", "")
            $squadID = New-VeracodeSquad $squadName
            Add-VeracodeSquadInTribe $squadID $tribeID
        }
    }
}