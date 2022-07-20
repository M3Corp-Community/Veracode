param (
        [parameter(position=0,Mandatory=$True)]
        $caminhoArquivo
)

# Função para pegar as credenciais com base no arquivo de configuração do IDE Scan/Greenlight
function Get-VeracodeCredentials {
    # Pega as credenciais do arquivo da Veracode
    $arquivoCredenciais = Get-Content -Path "$env:userprofile\.veracode\credentials"
    # Recebe os valores
    $VeracodeID = $arquivoCredenciais[1].Replace("veracode_api_key_id = ","")
    $APIKey = $arquivoCredenciais[2].Replace("veracode_api_key_secret = ","")
    # Configura a saida
    $veracodeCredenciais = $VeracodeID,$APIKey
    return $veracodeCredenciais
}

# Executa o Scan
try {
    # Carrega as credenciais
    $veracodeCredenciais = Get-VeracodeCredentials
    $veracodeID = $veracodeCredenciais[0]
    $veracodeAPIkey = $veracodeCredenciais[1]

    # Faz o Scan
    java -jar "pipeline-scan.jar" -vid $veracodeID -vkey $veracodeAPIkey -f $caminhoarquivo --issue_details true
}
catch {
    $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Erro ao fazer o scan em: $caminhoarquivo"
        Write-Host "$ErrorMessage"
}