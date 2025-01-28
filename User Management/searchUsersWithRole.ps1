# Roles names list:
# https://docs.veracode.com/r/c_identity_create_human

function Get-VeracodeRoleID {
    param (
        $roleShortName
    )
    
    $allRoles = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/roles?size=100"  | ConvertFrom-Json
    $allRoles = $allRoles._embedded.roles
    $roleID = ($allRoles | Where-Object { $_.role_name -eq "$roleShortName" }).role_id
    return $roleID
}

function Get-VeracodeUserWithRole {
    param (
        $role
    )
    
    $roleID = Get-VeracodeRoleID "$role"
    $usersList = http --auth-type=veracode_hmac GET "https://api.veracode.com/api/authn/v2/users/search?role_id=$roleID&size=10000" | ConvertFrom-Json
    $usersNamesList = $usersList._embedded.users.user_name
    return $usersNamesList  
}

# Ex:
Get-VeracodeUserWithRole "extsubmitter"