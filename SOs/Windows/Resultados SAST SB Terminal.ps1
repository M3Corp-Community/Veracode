[CmdletBinding()]
param (
    [Parameter()]
    $veracodeAppName,
    $SandBoxname
)

# Configuracoes
$numeroVersao = Get-Date -Format hhmmssddMMyy

# Recebe o App ID com base no nome da aplicacao dentro do Veracode
[xml]$INFO = $(VeracodeAPI.exe -action GetAppList | Select-String -Pattern $veracodeAppName)[0]
# Filtra o App ID
$appID = $INFO.app.app_id

try {
    # Pega o ID da SandBox
        [xml]$SBINFO = $(VeracodeAPI.exe -action getsandboxlist -appid $appID)
        $SandBoxID = ($SBINFO.sandboxlist.sandbox | Where-Object { $_.sandbox_name -eq "$SandBoxname" }).sandbox_id
        [xml]$buildINFO = $(VeracodeAPI.exe -action getbuildlist -appid $appID -sandboxid $SandBoxID)
        $buildIDList = $buildINFO.buildlist.build.build_id
        [array]::Reverse($buildIDList)
        $buildID = $buildIDList[0]
        # Gera o relatorio
        $out = VeracodeAPI.exe -action summaryreport -buildid "$buildID" -outputfilepath "$env:LOCALAPPDATA\$numeroVersao.xml"
        $securityINFO = [xml](Get-Content "$env:LOCALAPPDATA\$numeroVersao.xml")
        # Recebendo informacoes
        Clear-Host
        $notaLetra = $securityINFO.summaryreport.'static-analysis'.rating
        $notaScore = $securityINFO.summaryreport.'static-analysis'.score
        $quemEnviou = $securityINFO.summaryreport.submitter
        $politica = $securityINFO.summaryreport.policy_name
        $complicanceStatus = $securityINFO.summaryreport.policy_compliance_status
        # Exibe os resultados
        Write-Host "Resultado do Scan: $numeroVersao"
        Write-Host "Nome App: $veracodeAppName - App ID: $appID"
        Write-Host "Enviado por: $quemEnviou"
        Write-Host "Politica: $politica"
        Write-Host "SandBox: $SandBoxname"
        Write-Host "Nota: $notaLetra - Score: $notaScore - Resultado: $complicanceStatus"
        Write-Host "Lista dos problemas encontrados:"
        $levels = $securityINFO.summaryreport.severity.level
        [array]::Reverse($levels)
        foreach ($level in $levels) {
            $securityINFO.summaryreport.severity[$level].category
        }
}
catch {
    $ErrorMessage = $_.Exception.Message # Recebe o erro
    Write-Host "Erro ao validar o Scan e pegar os dados"
    Write-Host "$ErrorMessage"
}