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

function New-VeracodeScaAppLink {
    param (
        $appProfiles,
        $scaProjects
    )
    foreach ($appProfile in $appProfiles) {
        $appID = $appProfile.guid
        $appName = $appProfile.profile.name
        Write-Host "Validando projeto: $appName($appID)"
        $projectID = ($scaProjects | Where-Object { $_.name -like "*$appName" }).id
        if ($projectID) {
            if ($projectID.Count -eq 1) {
                Write-Host "SCA Project equivalente: $projectID"
                http --auth-type=veracode_hmac PUT "https://api.veracode.com/srcclr/v3/applications/$appID/projects/$projectID" | ConvertFrom-Json
            } else {
                Write-Host "Projeto com mais de um valor, recomendada validacao manual"
            }  
        }
        Start-Sleep 5 
    }
}