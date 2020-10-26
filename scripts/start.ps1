function Get-DockerProjectStatus {
    param (
        [string]$Project,
        [string]$Path
    )

    Set-Location $Path

    Write-Host "Project: $Project"
    Write-Host ""

    docker-compose up -d --build
    Write-Host ""
}

function Start-AllDockerProjects {
    param (
        [string]$RootDirectory,
        [array]$AllProjects
    )

    foreach ($Project in $AllProjects) {
        Get-DockerProjectStatus -Project $Project -Path "$RootDirectory\$Project"
    }    
}

$Projects = @(
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

Start-AllDockerProjects -RootDirectory $currentWorkingDir -AllProjects $Projects

Set-Location $currentWorkingDir
