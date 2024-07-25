function Get-VeracodeTeams {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.teams
    return $teamList
}

function New-VeracodeTeamLOG {
    param (
        $teamName
    )
    $jsonData = @{
        "team_name" = "$teamName"
    } | ConvertTo-Json
    $apiReturn = $jsonData | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/teams"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $newTeam = $apiReturn.team_name
    return $newTeam
}

function New-VeracodeLotOfTeams {
    param (
        $teamList,
        $currentTeams
    )
    foreach ($teamName in $teamList) {
        $valida = $currentTeams | Where-Object { $_.team_name -eq "$teamName" }
        if ($valida) {
            $currentTeam = $valida.team_name
            Write-Host "O time $currentTeam ja existe"
        } else {
            New-VeracodeTeamLOG $teamName
        }
        Start-Sleep 1
    }  
}

# Faz o processo:
$currentTeams = Get-VeracodeTeams # Recebe todos os times que existem na Veracode
$teamList = "Lista de times que precisam ser criados" # Lista de times que precisam ser criados
New-VeracodeLotOfTeams $teamList $currentTeams