      $sourcePath = Get-Location
      $destinationPath = "$(caminhoPacote)"

      # Filtrar os arquivos DLL
      $dllFiles = Get-ChildItem -Path $sourcePath -Filter *.dll -File -Recurse

      # Inicialize um array para armazenar os arquivos DLL e PDB correspondentes
      $filesToInclude = @()

      # Para cada arquivo DLL encontrado, verifique se há um arquivo PDB correspondente
      foreach ($dllFile in $dllFiles) {
          $pdbFile = Get-ChildItem -Path $sourcePath -Filter "$($dllFile.BaseName).pdb" -File -Recurse
          if ($pdbFile) {
              $filesToInclude += $dllFile.FullName
              $filesToInclude += $pdbFile.FullName
          }
      }

      # Se houver arquivos DLL e PDB correspondentes, criar o arquivo zip
      if ($filesToInclude.Count -gt 0) {
        foreach ($file in $filesToInclude) {
            Write-Host "$file"
            Compress-Archive -Path $file -Update -DestinationPath "$destinationPath"
            Write-Host "Arquivo zip criado com sucesso em: $destinationPath"
        }
      } else {
          Write-Host "Nenhum par de arquivos DLL e PDB correspondente encontrado."
      }