$sourcePath = Get-Location
$destinationPath = "$caminhoPacote"
New-Item -Path ".\UploadVeracode" -ItemType Directory

# Filtrar os arquivos DLL
$dllFiles = Get-ChildItem -Path $sourcePath -Include *.dll -File -Recurse | Where-Object { $_.FullName -notmatch 'Microsoft|UnitTest|Xunit|Test|\\obj\\|ref|refint' }

# Para cada arquivo DLL encontrado, verifique se há um arquivo PDB correspondente
foreach ($dllFile in $dllFiles) {
$pdbFile = Get-ChildItem -Path $sourcePath -Filter "$($dllFile.BaseName).pdb" -File -Recurse | Where-Object { $_.FullName -notmatch 'Microsoft|UnitTest|Xunit|Test|\\obj\\|ref|refint' }
if ($pdbFile) {
    Move-Item -Path $dllFile.FullName -Destination ".\UploadVeracode" -Verbose
    Move-Item -Path $pdbFile.FullName -Destination ".\UploadVeracode" -Verbose
    }
}
# Obtém todos os arquivos JSON no diretório de origem
$arquivosConfig = Get-ChildItem -Path $sourcePath -Include *.json, *.yml, *.xml
# Move cada arquivo JSON para o diretório de destino
foreach ($arquivo in $arquivosConfig) {
    Move-Item -Path $arquivo.FullName -Destination ".\UploadVeracode" -Verbose -Force
}

Compress-Archive -Path ".\UploadVeracode" -DestinationPath "$destinationPath"
Write-Host "Arquivo zip criado com sucesso em: $destinationPath"