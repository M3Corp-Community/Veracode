$sourcePath = Get-Location
$zipFiles = Get-ChildItem -Path $sourcePath -Include *.zip -File -Recurse
foreach ($zipFile in $zipFiles) {
    $veracodeAppProfile = $zipFile.FullName
    $caminhoPacote = $zipFile.FullName
    Write-Host "Veracode U&S: $veracodeAppProfile"
    java -jar veracode-wrapper.jar -vid $(VeracodeID) -vkey $(VeracodeKey) -action uploadandscan -appname $veracodeAppProfile -createprofile true  -version $(build.buildNumber) -filepath $caminhoPacote
}