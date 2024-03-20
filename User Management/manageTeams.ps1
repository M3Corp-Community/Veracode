function Get-VeracodeTeams {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.teams
    return $teamList
}

function Get-VeracodeTeamID {
    param (
        $teamName
    )

    $teamList = Get-VeracodeTeams
    $teamID = ($teamList | Where-Object { $_.team_name -eq "$teamName" }).team_id
    return $teamID
}

function New-VeracodeTeam {
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