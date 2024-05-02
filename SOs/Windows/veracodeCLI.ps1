# Guia rapido de Veracode CLI
# Doc completa: https://docs.veracode.com/r/CLI_Reference

# Função para pegar os arquivos validos para o Fix
function Get-VeracodeFixableFiles {
    param (
        $resultadosVeracode
    )
    $supportJS = @(73, 78, 80, 89, 113, 117, 209, 311, 312, 327, 352, 601, 611, 614)
    $listaArquivos = @()
    $vulnerabilidades = $resultadosVeracode.findings
    foreach ($vulnerabilidade in $vulnerabilidades) {
        $cweID = $vulnerabilidade.cwe_id
        if ($supportJS -contains $cweID) {
            $listaArquivos += $vulnerabilidade.files.source_file.file
        }
    }
    return $listaArquivos
}

# Faz a instalacao do Veracode CLI
Set-ExecutionPolicy AllSigned -Scope Process -Force
$ProgressPreference = "silentlyContinue"; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://tools.veracode.com/veracode-cli/install.ps1'))
veracode configure

# Faz uma analise Container/IaC
veracode scan --source alpine:latest --type image --format table
veracode scan --source ./IaC --type directory --format table

# Faz o empacotamento para analise
$caminhoPacote = (Get-Item $PWD).Name + ".zip"
veracode package -s .

# Faz uma analise SAST
veracode static scan $caminhoPacote

# Mapeia as falhas para o Fix
$caminhoResultados = "results.json"
$resultadosVeracode = Get-Content $caminhoResultados | ConvertFrom-Json
$listaArquivos = Get-VeracodeFixableFiles $resultadosVeracode

# Faz o Fix
veracode fix $listaArquivos[0]