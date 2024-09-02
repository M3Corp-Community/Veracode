function Get-VeracodeSCAWorkspaceID {
    param (
        $scaWorkspaceName
    )
    $scaWorkspaceList =  http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces?size=10000" | ConvertFrom-Json
    $scaWorkspaceList = $scaWorkspaceList._embedded.workspaces
    $scaWorkspaceID = ($scaWorkspaceList | Where-Object { $_.name -eq "$scaWorkspaceName" }).id
    return $scaWorkspaceID
}

function New-VeracodeSCAWorkspace {
    param (
        $scaWorkspaceName
    )
    $jsonData = @{
        "name" = "$scaWorkspaceName"
    }
    $json = $jsonData | ConvertTo-Json
    $apiReturn = $json | http --auth-type=veracode_hmac POST "https://api.veracode.com/srcclr/v3/workspaces"
    $apiReturn = $apiReturn | ConvertFrom-Json
}