param (
        [parameter(position=0,Mandatory=$True)]
        $caminhoArquivo
)

# Faz o Scan
java -jar "pipeline-scan.jar" -f $caminhoarquivo --issue_details true
# Pega o total de falhas encontradas
$retornoPS = Get-Content .\results.json | ConvertFrom-Json
$resultados = $retornoPS.findings
$totalResultados = $resultados.count
# Causa o erro com base nesse numero
exit $totalResultados