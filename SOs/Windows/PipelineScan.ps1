param (
        [parameter(position=0,Mandatory=$True)]
        $caminhoArquivo
)

# Executa o Scan
try {
    # Faz o Scan
    java -jar "pipeline-scan.jar" -f $caminhoarquivo --issue_details true
}
catch {
    $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Erro ao fazer o scan em: $caminhoarquivo"
        Write-Host "$ErrorMessage"
}