function Get-TeamsNamesFromUser {
    param (
        $nameUser
    )

    # Get basic info from a user
    $infoUser = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users?user_name=$nameUser"  | ConvertFrom-Json

    # Get user profile URL
    $userUrl = $infoUser._embedded.users._links.self.href

    # Get all info from a user
    $infoUser = http --auth-type=veracode_hmac GET $userUrl  | ConvertFrom-Json

    # Get all team names
    $userTeams = $infoUser.teams.team_name

    return $userTeams
}

function Get-TeamsIdsFromUser {
    param (
        $nameUser
    )

    # Get basic info from a user
    $infoUser = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users?user_name=$nameUser"  | ConvertFrom-Json

    # Get user profile URL
    $userUrl = $infoUser._embedded.users._links.self.href

    # Get all info from a user
    $infoUser = http --auth-type=veracode_hmac GET $userUrl  | ConvertFrom-Json

    # Get all team ids
    $userTeams = $infoUser.teams.team_id

    return $userTeams
}