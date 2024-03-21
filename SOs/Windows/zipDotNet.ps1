$sourcePath = Get-Location
$destinationPath = "$(caminhoPacote)"
New-Item -Path ".\UploadVeracode" -ItemType Directory

# Filtrar os arquivos DLL
$dllFiles = Get-ChildItem -Path $sourcePath -Filter *.dll -File -Recurse -Exclude "*Microsoft*", "*UnitTest*", "*Xunit*", "*Test*"

# Para cada arquivo DLL encontrado, verifique se há um arquivo PDB correspondente
foreach ($dllFile in $dllFiles) {
    $pdbFile = Get-ChildItem -Path $sourcePath -Filter "$($dllFile.BaseName).pdb" -File -Recurse
    if ($pdbFile) {
        Move-Item -Path $dllFile.FullName, $pdbFile.FullName -Destination ".\UploadVeracode" -Verbose
    }
}

Compress-Archive -Path ".\UploadVeracode" -DestinationPath "$destinationPath"
Write-Host "Arquivo zip criado com sucesso em: $destinationPath"