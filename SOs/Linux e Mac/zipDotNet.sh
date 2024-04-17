#!/bin/bash
# Diretório atual
diretorio_atual=$(pwd)

# Criar uma pasta temporária
pasta_temporaria=$(mktemp -d)

# Encontra todas as DLLs no diretório atual e subdiretórios
dlls=$(find "$diretorio_atual" -type f -name '*.dll')

# Para cada DLL encontrada, verifica se existe um PDB correspondente
for dll in $dlls; do
    pdb="${dll%.*}.pdb"
    if [ -f "$pdb" ]; then
        # Move DLL e PDB correspondente para a pasta temporária, forçando a substituição
        mv -f "$dll" "$pdb" "$pasta_temporaria"
    fi
done

# Cria um arquivo ZIP contendo a pasta temporária
if [ -n "$(ls -A "$pasta_temporaria")" ]; then
    zip -jr dlls_com_pdb.zip "$pasta_temporaria"
else
    echo "Nenhuma DLL com PDB correspondente encontrada."
fi

# Limpa a pasta temporária
rm -r "$pasta_temporaria"