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

function Get-VeracodeTeamCount {
    param (
        $teamList,
        $currentTeams
    )
    $exist = 0
    $noExist = 0
    foreach ($teamName in $teamList) {
        $valida = $currentTeams | Where-Object { $_.team_name -eq "$teamName" }
        if ($valida) {
            $currentTeam = $valida.team_name
            $exist++
            Write-Host "O time $currentTeam ja existe"
        } else {
            $noExist++
            Write-Host "Precisa criar $teamName"
        }
    }
    Write-Host "Ja existe: $exist - Precisa criar: $noExist"
}
