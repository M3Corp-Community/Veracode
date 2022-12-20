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

# Recebe a lista de todos os nomes e IDs
[xml]$listaPerfisApp = $(./VeracodeAPI.exe -action GetAppList)
$nomesApps = $listaPerfisApp.applist.app.app_name
$idApps = $listaPerfisApp.applist.app.app_id

# Define um prefixo para validação do nome e o indice
$validadorNome = "DELETAR"
[int]$indice = 0

# Valida se existe algum nome com o prefixo
foreach ($nomeApp in $nomesApps) {
    if ($nomeApp -like "*$validadorNome*") {
        $appID = $idApps[$indice]
        Write-Host "Removendo perfil: $nomeApp - $appID"
        [xml]$Status = ./VeracodeAPI.exe -action deleteapp -appid "$appID"

        # Faz a validacao
        $resultado = $status.deleteapp.result
        if ($resultado -eq "success") {
            Write-Host "O perfil $nomeApp foi removido com sucesso"
        } else {
            Write-Host "Erro ao deletar o perfil: $nomeApp"
            Write-Host $Status
        }
    }
    $indice = $indice + 1
}