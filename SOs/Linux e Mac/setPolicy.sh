# Parametros:
veracodeAppProfile=""
veracodePolicy=""

# Obtem as informacoes do projeto
INFO=$(java -jar veracode-wrapper.jar -action GetAppList)
appID=$(echo "$INFO" | grep -oP '(?<=app_id=")[^"]+(?=" app_name="'$veracodeAppProfile'")')

# Verifica se o appID foi extraido corretamente
if [ -n "$appID" ]; then
  # Faz a edicao
  java -jar veracode-wrapper.jar -action updateapp -appid $appID -policy "$veracodePolicy"
  echo "Add $veracodeAppProfile (ID: $appID) in Policy $veracodePolicy"
else
  echo "App ID não encontrado para o perfil $veracodeAppProfile"
fi