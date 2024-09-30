function Get-VeracodeScaWorkspaceID {
    param (
        $workspaceName
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces?size=10000" | ConvertFrom-Json
    $workspaceList = $apiReturn._embedded.workspaces
    $workspaceID = ($workspaceList | Where-Object { $_.name -eq "$workspaceName" }).id
    return $workspaceID
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

function Get-VeracodeScaWorkspaceTeams {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/srcclr/v3/teams?page=0&size=500" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/srcclr/v3/teams?page=$pageNumber&size=500" | ConvertFrom-Json
        $teamList += $apiReturn._embedded.teams
        # Incrementar o contador
        $pageNumber++
    }
    return $teamList
}

# Como usar:
function Add-AllTeamsInVeracodeScaWorkspace {
    param (
        $scaWorkspaceName
    )
    $workspaceID = Get-VeracodeScaWorkspaceID "$scaWorkspaceName"
    $teamList = Get-VeracodeScaWorkspaceTeams
    foreach ($team in $teamList) {
        Add-VeracodeTeamsInScaWorkspace $workspaceID $team
        Start-Sleep 1
    }
}
