function Get-VeracodeTribes {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/business_units?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.business_units
    return $teamList
}

function Get-VeracodeTribeDetails {
    param (
        $tribe
    )
    $returnInfo = @()
    $tribeID = $tribe.bu_id
    $tribeName = $tribe.bu_name
    $tribeTeams = $tribe.teams.team_name
    foreach ($tribeTeam in $tribeTeams) {
        $returnInfo += "$tribeTeam;$tribeID;$tribeName"
    }
    return $returnInfo
}

function Get-VeracodeAllSquadsInTribes {
    param (
        $allTribes
    )
    $returnInfo = @()
    foreach ($tribe in $allTribes) {
        $tribeID = $tribe.bu_id
        $tribeName = $tribe.bu_name
        $tribeTeams = $tribe.teams.team_name
        foreach ($tribeTeam in $tribeTeams) {
            $returnInfo += "$tribeTeam;$tribeID;$tribeName"
        }
    }
    return $returnInfo
}

function Get-VeracodeAppProfiles {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=5000" | ConvertFrom-Json
    $appProfiles = $apiReturn._embedded.applications
    return $appProfiles
}

function Get-VeracodeSquads {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.teams
    return $teamList
}

function Get-VeracodeTribeID {
    param (
        $squad,
        $tribeTeamsList
    )

    $squadName = $squad.team_name
    $tribeTeamsList | ForEach-Object {
        # Divida a linha pelo ponto e vírgula para obter os elementos
        $elements = $_ -split ';'
        # Verifique se o segundo elemento corresponde ao $teamName
        $currentTeam = $elements[0]
        Write-Host "Validando: $currentTeam"
        if ($currentTeam -eq $squadName) {
            # Se corresponder, imprima o ID (o terceiro elemento)
            $tribeID = $($elements[1])
            $tribeName = $($elements[2])
            Write-Output "ID encontrado para $squadName : $tribeName $tribeID"
            return $buID
        }
    }
}

# Pega todas as tribos
$allTribes = Get-VeracodeTribes
# Para cada tribo, pega os times que fazem parte dela
foreach ($tribe in $allTribes) {
    $tribeTeamsList = Get-VeracodeTribeDetails $tribe
    Write-Host "Validando tribo:" $tribe.bu_name
    # Verifica se o squad faz parte dessa tribo
    $tribeID = Get-VeracodeTribeID $squad $tribeTeamsList
    if ($null -ne $tribeID) {
        # Add a tribo ao app
        Write-Host "Bingo"
        break
    }
}

$squad = "squad"
$tribeTeamsList = Get-VeracodeAllSquadsInTribes $allTribes