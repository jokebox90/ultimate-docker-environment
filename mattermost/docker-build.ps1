$ErrorActionPreference = "Stop"

$imageName = "mattermost"
$sourceUrl = "https://github.com/mattermost/mattermost-docker.git"
$sourceDir = ".\src"

If (-Not (Test-Path -Path $sourceDir)) {
    New-Item -ItemType Directory -Path $sourceDir
}

Write-Host
Write-Host "*** Fetching sources..."
git clone $sourceUrl $SourceDir

Write-Host
Write-Host "*** Building image..."
docker build -t $imageName "$SourceDir\app"

Write-Host
Write-Host "--- Finished !"