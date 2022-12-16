# Funcao para excluir App Profiles
function Delete-VeracodeAppProfile {
    param (
        $appName
    )
    
    try {
        # Recebe o App ID com base no nome da aplicacao dentro do Veracode
        [xml]$INFO = $(./VeracodeAPI.exe -action GetAppList | Select-String -Pattern $appName)
        # Filtra o App ID
        $appID = $INFO.app.app_id

        # Remove o perfil informado
        Write-Host "Removendo perfil: $appName - $appID"
        [xml]$Status = ./VeracodeAPI.exe -action deleteapp -appid "$appID"

        # Faz a validacao
        $resultado = $status.deleteapp.result
        if ($resultado -eq "success") {
            Write-Host "O perfil $appName foi removido com sucesso"
        } else {
            Write-Host "Erro ao deletar o perfil: $appName"
            Write-Host $Status
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Erro ao deletar o perfil: $appName"
        Write-Host "$ErrorMessage"
    }
}

# Configura o Wrapper
$validador = Test-Path ./VeracodeAPI.exe
if ($validador -ne "True") {
    $urlDownloadAPI = "https://tools.veracode.com/integrations/API-Wrappers/C%23/bin/VeracodeC%23API.zip"
    Invoke-WebRequest -Uri "$urlDownloadAPI" -OutFile "VeracodeAPI.zip"
    Expand-Archive -Path "VeracodeAPI.zip" -Force
    Move-Item -Path "VeracodeAPI/VeracodeC#API.exe" -Destination "./VeracodeAPI.exe" -Force
    Remove-Item -Path VeracodeAPI -Recurse
    Remove-Item -Path VeracodeAPI.zip
}

# Define um prefixo para validação do nome
$validadorNome = "DELETAR"

# Recebe a lista de todos os nomes
[xml]$listaPerfisApp = $(./VeracodeAPI.exe -action GetAppList)
$nomesApps = $listaPerfisApp.applist.app.app_name

# Valida se existe algum nome com o prefixo
foreach ($nomeApp in $nomesApps) {
    if ($nomeApp -like "*$validadorNome*") {
        Delete-VeracodeAppProfile "$nomeApp"
    }
}