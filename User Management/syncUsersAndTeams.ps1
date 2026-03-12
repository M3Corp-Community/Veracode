# Conjunto de funções

function Get-VeracodeUsers {
    $userList = @()
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users?page=0&size=500" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0

    while ($pageNumber -ne $pages) {

        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users?page=$pageNumber&size=500" | ConvertFrom-Json
        $userList += $apiReturn._embedded.users

        $pageNumber++
    }

    return $userList
}

function Get-VeracodeTeams {
    $teamList = @()
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&page=0&size=500" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0

    while ($pageNumber -ne $pages) {

        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/teams?all_for_org=true&page=$pageNumber&size=500" | ConvertFrom-Json
        $teamList += $apiReturn._embedded.teams

        $pageNumber++
    }

    return $teamList
}

function Get-VeracodeUserID {
    param (
        $userEmail,
        $userList
    )

    $userID = ($userList | Where-Object { $_.user_name -eq "$userEmail" }).user_id
    return $userID
}

function Get-VeracodeTeamID {
    param (
        $teamName,
        $teamList
    )

    $teamID = ($teamList | Where-Object { $_.team_name -eq "$teamName" }).team_id
    return $teamID
}

function Sync-VeracodeTeamUser {
    param (
        $teamID,
        $teamName,
        $userEmail
    )

    $jsonData = @{
        team_name = $teamName
        users = @(
            @{
                user_name = $userEmail
            }
        )
    }

    $jsonBody = $jsonData | ConvertTo-Json -Depth 5
    $apiReturn = $jsonBody | http --auth-type=veracode_hmac PUT "https://api.veracode.com/api/authn/v2/teams/$teamID" `
        partial==true `
        incremental==true

    $apiReturn = $apiReturn | ConvertFrom-Json
    $user = $apiReturn.users | Where-Object { $_.user_name -eq $userEmail }

    if ($user) {
        Write-Host "SUCESSO: Usuário $userEmail associado ao time $teamName"
        return @{
            status  = "sucesso"
            usuario = $userEmail
            time    = $teamName
        }

    } else {
        Write-Host "ERRO: Usuário $userEmail não aparece associado ao time $teamName"
        return @{
            status  = "erro"
            usuario = $userEmail
            time    = $teamName
        }
    }
}

# Fluxo
$userList = Get-VeracodeUsers
$teamList = Get-VeracodeTeams

# Dados de entrada
$userEmail = "usuario@empresa.com"
$teamName = "DEMOs"

# Resolver IDs
$teamID = Get-VeracodeTeamID -teamName $teamName -teamList $teamList

# Sincronizar usuário no time
Sync-VeracodeTeamUser -teamID $teamID -teamName $teamName -userEmail $userEmail