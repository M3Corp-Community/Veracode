#!/bin/bash
sourcePath=$(pwd)
destinationPath="$caminhoPacote"
mkdir -p ./UploadVeracode

# Filtrar os arquivos DLL
dllFiles=$(find "$sourcePath" -type f -name "*.dll" | grep -Ev 'Microsoft|UnitTest|Xunit|Test|/obj/|ref|refint')

# Para cada arquivo DLL encontrado, verifique se há um arquivo PDB correspondente
for dllFile in $dllFiles; do
    pdbFile=$(find "$sourcePath" -type f -name "$(basename "$dllFile" .dll).pdb" | grep -Ev 'Microsoft|UnitTest|Xunit|Test|/obj/|ref|refint')
    if [ -n "$pdbFile" ]; then
        mv "$dllFile" "./UploadVeracode"
        mv "$pdbFile" "./UploadVeracode"
    fi
done

zip -r "$destinationPath" "./UploadVeracode"
echo "Arquivo zip criado com sucesso em: $destinationPath"