function New-VeracodeDAST-AuthHeader {
    param (
        $scanName,
        $targetURL,
        $headername,
        $headerToken
    )
    
    $configDAST = Get-Content templateAuthPause.json | ConvertFrom-Json
    $configDAST.name = $scanName
    $configDAST.scans.scan_config_request.target_url.url = $targetURL
    $configDAST.scans.scan_config_request.auth_configuration.authentications.HEADER.headers.key = $headername
    $configDAST.scans.scan_config_request.auth_configuration.authentications.HEADER.headers.value = $headerToken

    $newDAST = $configDAST | ConvertTo-Json -depth 100
    $apiReturn = $newDAST | http --auth-type=veracode_hmac POST "https://api.veracode.com/was/configservice/v1/analyses"
    return $apiReturn
}

function New-VeracodeDAST {
    param (
        $scanName,
        $targetURL
    )
    
    $configDAST = Get-Content templatePause.json | ConvertFrom-Json
    $configDAST.name = $scanName
    $configDAST.scans.scan_config_request.target_url.url = $targetURL

    $newDAST = $configDAST | ConvertTo-Json -depth 100
    $apiReturn = $newDAST | http --auth-type=veracode_hmac POST "https://api.veracode.com/was/configservice/v1/analyses"
    return $apiReturn
}