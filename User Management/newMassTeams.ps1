# Recebe uma lista de times
param (
    $teamsList
)

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

foreach ($team in $teamsList) {
    New-VeracodeTeam $team
}