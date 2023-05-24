# Configurações
$veracodeAppName = "ProjetoVeracode"

# Lista de SBs
$listaSB = Get-Content "D:\TEMP\lista.txt"
$listaSB = $listaSB.ToUpper()

# Recebe o App ID com base no nome da aplicacao dentro do Veracode
[xml]$INFO = $(VeracodeAPI.exe -action GetAppList | Select-String -Pattern $veracodeAppName)
# Filtra o App ID
$VeracodeAppID = $INFO.app.app_id

# Verifica se a lista de SBs já existe
[xml]$INFO = $(VeracodeAPI.exe -action getsandboxlist -appid "$VeracodeAppID")
$nomeSBs = $INFO.sandboxlist.sandbox.sandbox_name
foreach ($SB in $listaSB) {
    # Compara com as SBs existentes
    if ($SB -notin $nomeSBs) {
        Write-Host "$SB não está na listagem"
        VeracodeAPI.exe -action createsandbox -appid "$VeracodeAppID" -sandboxname "$SB"
        Write-Host "$SB foi criada"
    }
}