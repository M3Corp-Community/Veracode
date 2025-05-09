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
    $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects?type=agent&size=1000" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces/$workspaceID/projects?type=agent&page=$pageNumber&size=1000" | ConvertFrom-Json
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

# Teste:
$workspaceID = Get-VeracodeScaWorkspaceID $workspaceName
$scaProjects = Get-VeracodeScaProjectsList $workspaceID
$scaProjectID = ""
$VeracodeScaIssues = Get-VeracodeScaIssues $scaProjectID