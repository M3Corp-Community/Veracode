param (
    [Parameter(Mandatory=$true)]
    $teamList
)

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
    $credential = "$VeracodeID;$VeracodeKey"
    return $credential
}

function New-VeracodePipelineUser {
    param (
        $userName
    )

    $userID = New-VeracodeApiUser $userName

    if ($null -eq $userID) {
        $userID = Get-VeracodeUserID $userName
    } 
    $veracodeCredentials = New-VeracodeApiUserCredentials $userID
    $VeracodeID, $VeracodeKey = $veracodeCredentials.Split(';')
    Write-Host "Projeto: $userName"
    Write-Host "VeracodeID: $VeracodeID"
    Write-Host "VeracodeKey: $VeracodeKey"
}

# Faz a criação conforme os times da lista
foreach ($team in $teamList) {
    $team = $team -replace '[^\w\-]', '-'
    New-VeracodePipelineUser $team
}