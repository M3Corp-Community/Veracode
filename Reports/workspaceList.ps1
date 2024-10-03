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

function Get-VeracodeAppProfiles {
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=500" | ConvertFrom-Json
    $pages = $apireturn.page.total_pages
    $pageNumber = 0
    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=$pageNumber&size=500" | ConvertFrom-Json
        $appProfiles += $apiReturn._embedded.applications
        # Incrementar o contador
        $pageNumber++
    }
    return $appProfiles
}

# Recebe a lista dos Workspaces:
$workspaceList = Get-VeracodeScaWorkspaces
$scaProjectsList = ""
foreach ($workspace in $workspaceList) {
    $workspaceName = $workspace.name
    $workspaceID = $workspace.id
    Write-Host "Obtendo a lista de projetos do workspace: $workspaceName - ID: $workspaceID"
    $scaProjects = Get-VeracodeScaProjectsList $workspaceID
    foreach ($project in $scaProjects) {
        $scaProjectsList += $project.name + "`n"
    }
}

# Recebe a lista dos App Profiles:
$appProfiles = Get-VeracodeAppProfiles
$appProfiles = $appProfiles.profile.name

# Publica num arquivo os resultados:
$appProfiles | Out-File -FilePath "scaProjectsList.txt" -Encoding UTF8
$scaProjectsList | Out-File -FilePath "appProfiles.txt" -Encoding UTF8