# Função para obter todos os Application Profiles
function Get-VeracodeAppProfiles {
    $appProfiles = @()
    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications?page=0&size=500" | ConvertFrom-Json
    $pages = $apiReturn.page.total_pages
    $pageNumber = 0

    while ($pageNumber -ne $pages) {
        $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications?page=$pageNumber&size=500" | ConvertFrom-Json
        $appProfiles += $apiReturn._embedded.applications

        $pageNumber++
    }

    return $appProfiles
}

# Localizar GUID da aplicação
function Get-VeracodeAppGUID {
    param (
        $appName,
        $appProfiles
    )

    $appGUID = ($appProfiles | Where-Object { $_.profile.name -eq "$appName" }).guid
    return $appGUID
}

# Gerar SBOM
function Get-VeracodeSBOM {
    param (
        $appGUID,
        $appName
    )

    $apiReturn = http --auth-type=veracode_hmac GET "https://api.veracode.com/srcclr/sbom/v1/targets/$appGUID/cyclonedx?type=application"
    $apiReturn = $apiReturn | ConvertFrom-Json

    if ($apiReturn._embedded.errors) {
        $errorDetail = $apiReturn._embedded.errors[0].detail
        if ($errorDetail -like "*No Policy or Agent Scan*") {
            Write-Host "AVISO: Aplicação $appName não possui scan SCA recente."
            return @{
                status    = "sem_scan_sca"
                aplicacao = $appName
            }

        } else {
            Write-Host "ERRO: Falha ao gerar SBOM para $appName"
            return @{
                status    = "erro"
                aplicacao = $appName
                detalhe   = $errorDetail
            }
        }

    } else {
        Write-Host "SUCESSO: SBOM recuperado para $appName"
        return @{
            status    = "sucesso"
            aplicacao = $appName
            sbom      = $apiReturn
        }

    }
}

# Gerar SBOM com nome de arquivo seguro
function Convert-ToSafeFileName {
    param (
        $name
    )

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    foreach ($char in $invalidChars) {
        $name = $name.Replace($char, "-")
    }

    return $name
}

# Fluxo
$appProfiles = Get-VeracodeAppProfiles
$appName = "M3Corp-Community/NodeGoat"
$safeName = Convert-ToSafeFileName $appName
$appGUID = Get-VeracodeAppGUID -appName $appName -appProfiles $appProfiles
Get-VeracodeSBOM -appGUID $appGUID -appName "$appName" -outputFile "$safeName-sbom.json"