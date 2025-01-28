param (
    [string]$FilePath,    # Caminho do arquivo JSON
    [int]$SeverityLevel   # Nível de severidade para remoção (ex.: 4 ou 5)
)

# Verifica se o arquivo existe
if (-Not (Test-Path $FilePath)) {
    Write-Host "Erro: Arquivo não encontrado no caminho '$FilePath'." -ForegroundColor Red
    exit 1
}

if ($SeverityLevel -lt 1 -or $SeverityLevel -gt 5) {
    Write-Host "Erro: O nível de severidade deve estar entre 1 e 5." -ForegroundColor Red
    exit 1
}

# Carregar o JSON
try {
    $jsonContent = Get-Content $FilePath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Erro: Não foi possível carregar o arquivo JSON. Verifique o formato do arquivo." -ForegroundColor Red
    exit 1
}

# Filtrar as findings e remover as severidades iguais ou maiores que o nível especificado
$jsonContent.findings = $jsonContent.findings | Where-Object { $_.severity -lt $SeverityLevel }

# Salvar o JSON atualizado de volta ao arquivo
try {
    $jsonContent | ConvertTo-Json -Depth 100 | Set-Content $FilePath
    Write-Host "Itens com severidade maior ou igual a $SeverityLevel foram removidos do arquivo '$FilePath'." -ForegroundColor Green
} catch {
    Write-Host "Erro: Não foi possível salvar as alterações no arquivo." -ForegroundColor Red
    exit 1
}