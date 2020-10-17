$ErrorActionPreference = "Stop"

$imageName = "codimd"

Write-Host
Write-Host "*** Building image..."
docker build -t $imageName .

Write-Host
Write-Host "--- Finished !"