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

function Traduzir-Resultados {
    param (
        $jsonResultados
    )
    # Recebe os valores
    $retornoPS = Get-Content $jsonResultados | ConvertFrom-Json
    $resultados = $retornoPS.findings
    foreach ($resultado in $resultados) {
        # Organiza os valores
        $titulo = $resultado.issue_type
        $cweID = $resultado.cwe_id
        $severidade = $resultado.severity
        $arquivo = $resultado.files.source_file.file
        $linha = $resultado.files.source_file.line
        $funcao = $resultado.files.source_file.function_name
        $descricaoFalha = $resultado.display_text
        $linkOrientacoes = $resultado.flaw_details_link
        # Traduz o texto
        $descricaoFalha = Traduzir $descricaoFalha
        # Exibe as informacoes
        Write-Host "Prioridade: $severidade - Falha: $titulo - CWE: $cweID"
        Write-Host "Arquivo: $arquivo - Linha: $linha - Função: $funcao"
        Write-Host "Descrição:"
        Write-Host "$descricaoFalha"
        Write-Host "Link com orientações de remediação: $linkOrientacoes"
        Write-Host " "
    }
}

function New-PipelineScan {
    param (
        $caminhoArquivo
    )
    # Download e configuração: Pipeline Scan
    $urlDownload = "https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip" # Define a url de download
    $caminhoDownload = "VeracodePipeline.zip" # Define um caminho para o arquivo de download
    Invoke-WebRequest -Uri "$urlDownload" -OutFile "$caminhoDownload" # Faz o download
    Expand-Archive -Path "$caminhoDownload" -DestinationPath "." # Descompacta o ZIP para uma pasta
    Remove-Item "$caminhoDownload" # Remove o arquivo de download

    # Faz o scan
    java -jar "pipeline-scan.jar" -f $caminhoarquivo
}