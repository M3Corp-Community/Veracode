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
    $credential = "$VeracodeID,$VeracodeKey"
    return $credential
}

# Test values:
$userName = "Teste-API"
$userID = Get-VeracodeUserID $userName
$credentials = New-VeracodeApiUserCredentials $userID
return $credentials