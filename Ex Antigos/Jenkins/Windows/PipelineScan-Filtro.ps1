param (
        [parameter(position=0,Mandatory=$True)]
        $caminhoArquivo
)

# Configuracoes
$filtroSeveridade = "Very High, High"

# Faz o Scan
java -jar "pipeline-scan.jar" -f $caminhoarquivo --issue_details true --fail_on_severity= "$filtroSeveridade"
# Pega o total de falhas encontradas
$retornoPS = Get-Content .\filtered_results.json | ConvertFrom-Json
$resultados = $retornoPS.findings
$totalResultados = $resultados.count
# Causa o erro com base nesse numero
exit $totalResultados