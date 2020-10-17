$imageName = "nexus3"
$sourceUrl = "https://github.com/sonatype-nexus-community/nexus-repository-composer.git"
$sourceDir = (Get-Item .\src).FullName

Write-Host
Write-Host "*** Fetching sources..."
git clone $sourceUrl $SourceDir
Set-Location $SourceDir

Write-Host
Write-Host "*** Building image..."
docker build -t $imageName .

Write-Host
Write-Host "--- Finished !"