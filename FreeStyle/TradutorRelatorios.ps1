# Funciona copiando e colando o conteudo no terminal, mas não quando chamamos o script .ps1

# Configuracoes
$caminhoArquivoXML = ""

function Traduzir {
    param (
        [parameter(position=0,Mandatory=$True)]
        $texto,
        [parameter(position=1)]
        $idiomaAlvo = "pt"
    )

    # Utiliza a API do Google para traduzir
    Try {
        $Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($idiomaAlvo)&dt=t&q=$texto”
        $Response = Invoke-RestMethod -Uri $Uri -Method Get
        # Retorna o valor traduzido
        $traducao = $Response[0].SyncRoot | foreach { $_[0] }
        return $traducao
    }
    Catch {
        # Recebe o erro
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        # Exibe a mensagem de erro
        Write-Host "Erro ao traduzir"
        Write-host $ErrorMessage
    }
}

# Recebendo informacoes
$securityINFO = [xml](Get-Content "$caminhoArquivoXML")
$notaLetra = $securityINFO.detailedreport.'static-analysis'.rating
$notaScore = $securityINFO.detailedreport.'static-analysis'.score
$veracodeAppName = $securityINFO.detailedreport.app_name
$numeroVersao = $securityINFO.detailedreport.version
$appID = $securityINFO.detailedreport.app_id
$quemEnviou = $securityINFO.detailedreport.submitter
$politica = $securityINFO.detailedreport.policy_name
$complicanceStatus = $securityINFO.detailedreport.policy_compliance_status
# Exibe os resultados
Write-Host "Resultado do Scan: $numeroVersao"
Write-Host "Nome App: $veracodeAppName - App ID: $appID"
Write-Host "Enviado por: $quemEnviou"
Write-Host "Politica: $politica"
Write-Host "Nota: $notaLetra - Score: $notaScore - Resultado: $complicanceStatus"
Write-Host "Lista dos problemas encontrados:"
# Recebe os leveis e reordena
$levels = $securityINFO.detailedreport.severity.level
[array]::Reverse($levels)
foreach ($level in $levels) {
    Write-Host "Prioridade: $level"
    # Recebe as informações
    $itensCategoria = $securityINFO.detailedreport.severity[$level].category
    foreach ($item in $itensCategoria) {
        $idCWE = $item.cwe.cweid
        $nomeCategoria = $item.categoryname
        $descricao = $item.desc.para.text
        $recomendacoes = $item.recommendations.para.text
        # Faz a tradução
        $descricao = Traduzir $descricao
        $recomendacoes = Traduzir $recomendacoes
        # Exibe o resultado
        Write-Host "Categoria: $nomeCategoria - ID CWE: $idCWE"
        Write-Host "Descrição: $descricao"
        Write-Host " "
        Write-Host "Remediação: $recomendacoes"
        Write-Host " "
        Write-Host " "
    }
    Write-Host "..."
}