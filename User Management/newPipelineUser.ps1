
function New-VeracodeApiUser {
    param (
        $userName
    )
    
    $infoUser = Get-Content apiUserTemplate.json | ConvertFrom-Json
    $infoUser.user_name = "$userName"
    $infoUser.first_name = "Integrador"
    $infoUser.last_name = "$userName"

    $newUser = $infoUser | ConvertTo-Json -depth 100
    $apiReturn = $newUser | http --auth-type=veracode_hmac POST "https://api.veracode.com/api/authn/v2/users"
    $apiReturn = $apiReturn | ConvertFrom-Json
    $userID = $apiReturn.user_id 
    return $userID
}

function Get-VeracodeUserID {
    param (
        $userName
    )
    $infoUsers = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users?size=10000" | ConvertFrom-Json
    $infoUsers = $infoUsers._embedded.users
    $userID = ($infoUsers | Where-Object { $_.user_name -eq "$userName" }).user_id
    return $userID
}

function New-VeracodeApiUserCredentials {
    param (
        $userID
    )
    $infoUser = http --auth-type=veracode_hmac --json POST "https://api.veracode.com/api/authn/v2/api_credentials/user_id/$userID"  | ConvertFrom-Json
    $VeracodeID = $infoUser.api_id
    $VeracodeKey = $infoUser.api_secret
    $expirationDate = $infoUser.expiration_ts
    $credential = "$VeracodeID;$VeracodeKey;$expirationDate"
    return $credential
}

function Get-VeracodeSCAWrokspace {
    param (
        $scaWorkspaceName
    )
    $scaWorkspaceList =  http --auth-type=veracode_hmac "https://api.veracode.com/srcclr/v3/workspaces?size=10000" | ConvertFrom-Json
    $scaWorkspaceList = $scaWorkspaceList._embedded.workspaces
    $scaWorkspaceID = ($scaWorkspaceList | Where-Object { $_.name -eq "$scaWorkspaceName" }).id
    return $scaWorkspaceID
}

function New-VeracodeVaultSecret {
    param (
        $keyVaultName,
        $veracodeCredentials
    )
    $VeracodeID, $VeracodeKey, $expirationDate = $veracodeCredentials.Split(';')
}

function Get-VeracodePipelineUser {
    param (
        $userName
    )

    $vaultList = Get-AzKeyVault
    $validatedUser = $vaultList.Name -contains $userName

    if ($validatedUser) {
        $veracodeSecrets = Get-AzKeyVaultSecret -VaultName $userName
    }
    
}