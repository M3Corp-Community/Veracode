$veracodeAppName = ""
$businessUnit = ""

# Recebe o App ID com base no nome da aplicacao dentro do Veracode
[xml]$INFO = $(java -jar veracode-wrapper.jar -vid $(VERACODE_API_KEY_ID) -vkey $(VERACODE_API_KEY_SECRET) -action GetAppList | Select-String -Pattern $veracodeAppName)[0]
# Filtra o App ID
$appID = $INFO.app.app_id
# Faz a modificação de BU
Write-Host "Add $veracodeAppName (ID: $appID) in $businessUnit"
java -jar veracode-wrapper.jar -vid $(VERACODE_API_KEY_ID) -vkey $(VERACODE_API_KEY_SECRET) -action updateapp -appid $appID -businessunit "$businessUnit"