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

function Get-VeracodeScaWorkspaceID {
    param (
        $workspaceName
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces" | ConvertFrom-Json
    $workspaceList = $apiReturn._embedded.workspaces
    $workspaceID = ($workspaceList | Where-Object { $_.name -eq "$workspaceName" }).id
    return $workspaceID
}

function Get-VeracodeScaProjectsList {
    param (
        $workspaceID
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects?type=agent" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        Write-Host "Page: $pageNumber"
        $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects?type=agent&page=$pageNumber" | ConvertFrom-Json
        $scaProjects += $apiReturn._embedded.projects
        # Incrementar o contador
        $pageNumber++
    }
    #$scaProjects = $apiReturn._embedded.projects
    return $scaProjects
}

function Get-VeracodeScaIssues {
    param (
        $scaProjectID
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects/$scaProjectID/issues?ignored=False&severity_gte=7" | ConvertFrom-Json
    $VeracodeScaIssues = $apiReturn._embedded.issues
    return $VeracodeScaIssues
}

function Get-VeracodeScaProjectID {
    param (
        $scaProjectName,
        $workspaceID
    )
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects?search=$scaProjectName" | ConvertFrom-Json
    # Pega o ultimo resultado por ser o mais recente (Pode ser interessante pensar numa forma melhor)
    $lastIndex = $apiReturn._embedded.projects.Count - 1
    $scaProjectID = $apiReturn._embedded.projects.id[$lastIndex]
    return $scaProjectID
}

# Teste:
#$workspaceList = Get-VeracodeScaWorkspaces
$workspaceID = Get-VeracodeScaWorkspaceID $workspaceName
#$scaProjects = Get-VeracodeScaProjectsList $workspaceID
$scaProjectID = Get-VeracodeScaProjectID $scaProjectName $workspaceID
$VeracodeScaIssues = Get-VeracodeScaIssues $scaProjectID