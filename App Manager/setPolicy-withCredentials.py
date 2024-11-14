import subprocess
import re
import argparse
import os

# Configuração dos argumentos de linha de comando
parser = argparse.ArgumentParser(description="Script to update Veracode application policy.")
parser.add_argument("veracodeAppProfile", help="The Veracode application profile name.")
parser.add_argument("veracodePolicy", help="The Veracode policy to apply.")
args = parser.parse_args()

# Parâmetros
veracodeAppProfile = args.veracodeAppProfile
veracodePolicy = args.veracodePolicy
vid = os.getenv("VID")     # Obtém o VID das variáveis de ambiente
vkey = os.getenv("VKEY")   # Obtém o VKEY das variáveis de ambiente

# Função para executar um comando e retornar a saída
def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout

# Obtém as informações do projeto
info = run_command(f"java -jar veracode-wrapper.jar -vid {vid} -vkey {vkey} -action GetAppList")

# Extrai o appID com base no veracodeAppProfile
app_id_match = re.search(f'app_id="([^"]+)" app_name="{veracodeAppProfile}"', info)
appID = app_id_match.group(1) if app_id_match else None

# Verifica se o appID foi extraído corretamente
if appID:
    # Faz a edição
    run_command(f'java -jar veracode-wrapper.jar -vid {vid} -vkey {vkey} -action updateapp -appid {appID} -policy "{veracodePolicy}"')
    print(f"Added {veracodeAppProfile} (ID: {appID}) to Policy {veracodePolicy}")
else:
    print(f"App ID not found for profile {veracodeAppProfile}")
