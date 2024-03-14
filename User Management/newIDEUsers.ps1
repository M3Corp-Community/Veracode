# Cria os usuarios para uso local com base no nome do computador e do usuario logado
function New-VeracodeApiUser {
    param (
        $userName,
        $currentUserName,
        $workstationName
    )
    
    $infoUser = Get-Content apiUserTemplate.json | ConvertFrom-Json
    $infoUser.user_name = $userName
    $infoUser.first_name = $currentUserName
    $infoUser.last_name = $workstationName

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
    $credential = "$VeracodeID,$VeracodeKey"
    return $credential
}

function New-VeracodeCredentialsFile {
    param (
        $credential
    )
    $VeracodeID, $VeracodeKey = $credential.Split(',')
    $credentialsFilePath = "$env:USERPROFILE\.veracode\credentialsTeste"
    $template = @"
[default]
veracode_api_key_id = $VeracodeID
veracode_api_key_secret = $VeracodeKey
"@

    $template | Out-File -FilePath $credentialsFilePath -Encoding utf8 -Force
}

$workstationName = $env:COMPUTERNAME
$currentUserName = $env:USERNAME
$userName = "$workstationName-$currentUserName"

$userID = Get-VeracodeUserID "$userName"
if (-not [string]::IsNullOrWhiteSpace($userID)) {
    Write-Host "Usuário do Veracode já cadastrado: $userName - $userID"
} else {
    $userID = New-VeracodeApiUser "$userName" "$currentUserName" "$workstationName"
}
$credentials = New-VeracodeApiUserCredentials $userID
New-VeracodeCredentialsFile $credentials