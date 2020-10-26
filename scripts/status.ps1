function Get-DockerServiceStatus {
    param (
        [string]$Name,
        [string]$Path
    )

    Set-Location $Path

    Write-Host "Service: $Name"
    Write-Host ""

    docker-compose ps
    Write-Host ""
}

function Get-AllDockerServicesStatus {
    param (
        [string]$RootDirectory,
        [array]$AllServices
    )

    foreach ($service in $AllServices) {
        Get-DockerServiceStatus -Name $service -Path "$RootDirectory\$service"
    }    
}

$services = @(
    "consul",
    "registrator",
    "fabio",
    "openproject",
    "gitlab",
    "nexus3",
    "mattermost",
    "codimd"
)

$currentWorkingDir = $(Get-Location)

Get-AllDockerServicesStatus -RootDirectory $currentWorkingDir -AllServices $services

Set-Location $currentWorkingDir
