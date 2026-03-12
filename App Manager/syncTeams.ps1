# Conjunto de funções:
function Get-VeracodeAppProfiles {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=500" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=$pageNumber&size=500" | ConvertFrom-Json
        $appProfiles += $apiReturn._embedded.applications
        # Incrementar o contador
        $pageNumber++
    }
    return $appProfiles
}
function Get-VeracodeTeams {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.teams
    return $teamList
}

function Get-VeracodeTeamID {
    param (
        $teamName,
        $teamList
    )

    $teamID = ($teamList | Where-Object { $_.team_name -eq "$teamName" }).team_id
    return $teamID
}

function Get-VeracodeAppGUID {
    param (
        $appName,
        $appProfiles
    )

    $appGUID = ($appProfiles | Where-Object { $_.profile.name -eq "$appName" }).guid
    return $appGUID
}

function Sync-VeracodeAppTeam {
    param (
        $appGUID,
        $teamGUID
    )

    $apiReturn = http --auth-type=veracode_hmac PATCH "https://api.veracode.com/appsec/v1/applications/$appGUID" `
        add_teams:='["'$teamGUID'"]' | ConvertFrom-Json

    $team = $apiReturn.profile.teams | Where-Object { $_.guid -eq $teamGUID }

    if ($team) {
        Write-Host "SUCESSO: Time $($team.team_name) associado à aplicação $($apiReturn.profile.name)"
        return @{
            status    = "sucesso"
            aplicacao = $apiReturn.profile.name
            time      = $team.team_name
        }

    } else {
        Write-Host "ERRO: Time $teamGUID não aparece associado à aplicação $($apiReturn.profile.name)"
        return @{
            status    = "erro"
            aplicacao = $apiReturn.profile.name
            teamGUID  = $teamGUID
        }

    }
}

# Fluxo:
# Recebe todos os times e os App Profiles
$appProfiles = Get-VeracodeAppProfiles
$teamList = Get-VeracodeTeams
# Considerando que recebemos como dados de entrada o time "DEMOs" e o App Profile "NodeGoat-JS-MB", vamos buscar os IDs de ambos
$appGUID = Get-VeracodeAppGUID -appName "NodeGoat-JS-MB" -appProfiles $appProfiles
$teamGUID = Get-VeracodeTeamID -teamName "DEMOs" -teamList $teamList
# Agora, vamos sincronizar o time com o App Profile
Sync-VeracodeAppTeam -appGUID $appGUID -teamGUID $teamGUID