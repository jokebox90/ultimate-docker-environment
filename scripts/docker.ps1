Param (
    [string]$Action,
    [string]$Project,
    [string]$Service
)

$ErrorActionPreference = "stop"

function Program {
    Param (
        [string]$Action,
        [string]$Project,
        [string]$Service
    )
    
    $location = (Get-Location).Path
    $allProjects = Get-Project -Name $Project

    if (-Not $Action -in @("start", "status")) {
        [array]::Reverse($allProjects)
    }

    foreach ($item in $allProjects) {
        $directory = "$($location)\$($item.Name)"
        $file = "$($location)\$($item.Name)\docker-compose.yml"

        if (-Not (Test-Path $directory)) {
            DisplayError "directory not found: $directory."
            exit
        }

        if (-Not (Test-Path $file)) {
            DisplayError "file not found: $file."
            exit
        }
    }

    foreach ($item in $allProjects) {
        $directory = "$($location)\$($item.Name)"
        $file = "$($location)\$($item.Name)\docker-compose.yml"

        Write-Host "---"
        Write-Host "--- Project: $($item.Name)"
        Write-Host "--- GitUrl: $($item.GitUrl)"
        Write-Host "---"

        if ($item.GitUrl -And -Not (Test-Path "$($Directory)\src")) {
            PullProjectSources -GitUrl $item.GitUrl -Destination "$($directory)\src" -Refs $item.GitRefs
        }

        switch ($Action)
        {
            "status" { ProjectStatus -File $file -Directory $directory -Service $Service; Break }
            "start" { ProjectStart -File $file -Directory $directory -Service $Service; Break }
            "stop" { ProjectStop -File $file -Directory $directory -Service $Service; Break }
            "recreate" { ProjectRecreate -File $file -Directory $directory -Service $Service; Break }
        }
    }
}

function Get-ProjectConfiguration {
    $configDir = (Get-Location).Path
    $configFile = "$configDir\projects.xml"

    if (-Not (Test-Path $configFile)) {
        Write-Host "Error" -ForegroundColor Red -NoNewline
        Write-Host ": configuration file not found: $configFile"
        exit
    }

    [xml]$configXml = Get-Content $configFile
    return $configXml.Projects
}

function Get-Project {
    Param (
        [string]$Name
    )

    $projectXml = (Get-ProjectConfiguration).Project
    $projectList = [System.Collections.ArrayList]@()

    foreach ($item in $projectXml) {
        if ($Name -And -Not ($Name -Eq $item.Name)) {
            continue
        }

        $projectObj = [pscustomobject]@{
            Name = $item.Name
            GitUrl = $item.GitUrl
        }

        [void]$projectList.Add($projectObj)
    }

    return $projectList
}

function PullProjectSources {
    Param (
        [string]$GitUrl,
        [string]$Destination,
        [string]$Refs = "master"
    )

    git clone -b $Refs $GitUrl $Destination
}

function ProjectStatus {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose --file $File --project-directory $Directory ps $Service
}

function ProjectStart {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose --file $File --project-directory $Directory up -d --build $Service
}

function ProjectStop {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    if ($Service) {
        docker-compose --file $File --project-directory $Directory rm --force --stop $Service
    } else {
        docker-compose --file $File --project-directory $Directory down   
    }
}

function ProjectRecreate {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose --file $File --project-directory $Directory up -d --build --force-recreate $Service
}

function DisplayError {
    Param (
        [string]$Message
    )
    
    Write-Host "Error" -ForegroundColor Red -NoNewline
    Write-Host ": $Message"
}

Program -Action $Action -Project $Project -Service $Service
