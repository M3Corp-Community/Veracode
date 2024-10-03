# Workspace Funcions
function Get-VeracodeScaWorkspaces {
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/?size=1000" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/?page=$pageNumber&size=1000" | ConvertFrom-Json
        $workspaceList += $apiReturn._embedded.workspaces
        # Incrementar o contador
        $pageNumber++
    }
    #$workspaceList = $apiReturn._embedded.workspaces
    return $workspaceList
}

function Add-VeracodeTeamsInScaWorkspace {
    param (
        $workspaceID,
        $team
    )
    $teamName = $team.name
    $teamID = $team.id
    $urlAPI = "https://api.veracode.com/srcclr/v3/workspaces/" + $workspaceID + "/teams/" + $teamID
    $teamLink = http --auth-type=veracode_hmac PUT "$urlAPI" | ConvertFrom-Json
    if ($teamLink) {
        Write-Host "Erro ao adicionar o time $teamName ao workspace"
    } else {
        Write-Host "Adicionado o time $teamName ao workspace"
    }
}

function Get-VeracodeScaWorkspaceID {
    param (
        $workspaceName
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces?size=10000" | ConvertFrom-Json
    $workspaceList = $apiReturn._embedded.workspaces
    $workspaceID = ($workspaceList | Where-Object { $_.name -eq "$workspaceName" }).id
    return $workspaceID
}

function New-VeracodeScaWorkspace {
    param (
        $workspaceName
    )
    $jsonData = @{
        "name" = "$workspaceName"
    }
    $jsonNew = $jsonData | ConvertTo-Json
    $apiReturn = $jsonNew | http --auth-type=veracode_hmac POST "https://api.veracode.com/srcclr/v3/workspaces/"
    $apiReturn = $apiReturn | ConvertFrom-Json
    if ($apiReturn) {
        $apiReturn
    } else {
        Write-Host "Criado o workspace $workspaceName"
    }
}

function New-VeracodeScaAgent {
    param (
        $workspaceID,
        $agentName = "CLI-Agent"
    )
    $jsonData = @{
        "agent_type" = "CLI"
        "name" = "$agentName"
    }
    $jsonNew = $jsonData | ConvertTo-Json
    $apiReturn = $jsonNew | http --auth-type=veracode_hmac POST "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/agents"
    $apiReturn = $apiReturn | ConvertFrom-Json
    if ($apiReturn) {
        Write-Host "Criado o agent, favor anotar o token retornado"
        $scaToken = $apiReturn.token.access_token
        return $scaToken
    } else {
        Write-Host "Erro ao criar o agent $agentName"
    }
}

# Squads (Teams) and Tribes (BUs)
function Get-VeracodeTribes {
    $infoTeam = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/business_units?all_for_org=true&size=10000" | ConvertFrom-Json
    $teamList = $infoTeam._embedded.business_units
    return $teamList
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
        Write-Host "Criando tribo: $tribeName"
        $jsonTribe = $jsonData | ConvertTo-Json
        $apiReturn = $jsonTribe | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/business_units"
        $apiReturn = $apiReturn | ConvertFrom-Json
        $tribeID = $apiReturn.bu_id
    }
    return $tribeID
}

function Add-VeracodeSquadsInWorkspaceTribe {
    param (
        $allTribes
    )
    foreach ($tribe in $allTribes) {
        $tribeName = $tribe.bu_name
        Write-Host "Configurando tribo $tribeName"
        $workspaceName = $tribeName -replace ' ', '_'
        $workspaceID = Get-VeracodeScaWorkspaceID $workspaceName
        if ($workspaceID) {
            $tribeTeams = $tribe.teams.team_name
            foreach ($tribeTeam in $tribeTeams) {
                Write-Host "Add Squad $tribeTeam no workspace $workspaceName"
                Add-VeracodeTeamsInScaWorkspace $workspaceID $tribeTeam
            }
        }
    }
}

# Fluxo 1
# Quando criar uma nova Tribo, cria um workspace de mesmo nome
$tribeName = "Teste-Tribo123"
$tribeList = Get-VeracodeTribes
New-VeracodeTribe $tribeName $tribeList
New-VeracodeScaWorkspace $tribeName

# Fluxo 2
# Cria um novo agente e retorna o token dele
$workspaceID = Get-VeracodeScaWorkspaceID $tribeName
$scaToken = New-VeracodeScaAgent $workspaceID

# Fluxo 3
# Atualiza a lista de times que podem acessar um workspace com base nas tribos
$allTribes = Get-VeracodeTribes
Add-VeracodeSquadsInWorkspaceTribe $allTribes

# Fluxo 4
# Para cada tribo atual, cria um workspace
$allTribes = Get-VeracodeTribes
$logNamesAndTokens = ""
foreach ($tribe in $allTribes) {
    $tribeName = $tribe.bu_name
    $workspaceName = $tribeName -replace ' ', '_'
    New-VeracodeScaWorkspace $workspaceName
    # Gera o LOG com o token para cadastro em um cofre
    $workspaceID = Get-VeracodeScaWorkspaceID $tribeName
    $scaToken = New-VeracodeScaAgent $workspaceID
    $logNamesAndTokens += "$workspaceName;$scaToken`n"
}