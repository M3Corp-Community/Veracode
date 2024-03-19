function Get-VeracodeSCAWrokspaceID {
    param (
        $scaWorkspaceName
    )
    $scaWorkspaceList =  http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces?size=10000" | ConvertFrom-Json
    $scaWorkspaceList = $scaWorkspaceList._embedded.workspaces
    $scaWorkspaceID = ($scaWorkspaceList | Where-Object { $_.name -eq "$scaWorkspaceName" }).id
    return $scaWorkspaceID
}