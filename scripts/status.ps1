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

function Fn-GetServiceStatus {
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


$currentWorkingDir = $(Get-Location)

foreach ($serviceName in $services) {
    $serviceWorkingDir = "$currentWorkingDir\$serviceName"
    Fn-GetServiceStatus -Name $serviceName -Path $serviceWorkingDir
}

Set-Location $currentWorkingDir