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
    
    $currentLocation = (Get-Location).Path
    $allProjects = GetProject -Name $Project

    if (-Not $Action -in @("start", "status")) {
        [array]::Reverse($allProjects)
    }
    
    foreach ($item in $allProjects) {
        
        Write-Host "---"
        Write-Host "--- Project: $($item.Name)"
        Write-Host "--- GitUrl: $($item.GitUrl)"
        Write-Host "---"
        RunAction -Action $Action -Location $currentLocation -Name $item.Name -Service $Service
        # if ($actionResult.Code -Gt 0) {
        #     DisplayError $actionResult.Message
        #     exit
        # }
    }
}


function RunAction {
    Param (
        [string]$Location,
        [string]$Action,
        [string]$Name,
        [string]$Service
    )

    $project = GetProject -Name $Name

    $directory = "$($Location)\$($project.Name)"
    $file = "$($Location)\$($project.Name)\docker-compose.yml"

    if ($project.GitUrl -And -Not (Test-Path "$($directory)\src")) {
        PullProject -GitUrl $project.GitUrl -Destination "$($directory)\src" -Refs $project.GitRefs
    }

    switch ($Action)
    {
        "status" { CmdStatus -File $file -Directory $directory -Service $Service; Break }
        "start" { CmdStart -File $file -Directory $directory -Service $Service; Break }
        "stop" { CmdStop -File $file -Directory $directory -Service $Service; Break }
        "recreate" { CmdRecreate -File $file -Directory $directory -Service $Service; Break }
    }
}


function GetProject {
    Param (
        [string]$Name = ""
    )

    $configDir = (Get-Location).Path
    $configFile = "$configDir\projects.xml"

    if (-Not (Test-Path $configFile)) {
        DisplayError "configuration file not found: $configFile"
        exit
    }

    [xml]$configXml = Get-Content $configFile

    if (-Not $Name -EQ "") {
        return $configXml.Projects.Project | Where-Object -Property Name -eq $Name
    } else {
        return $configXml.Projects.Project
    }
}

function PullProject {
    Param (
        [string]$GitUrl,
        [string]$Destination,
        [string]$Refs = "master"
    )

    git clone -b $Refs $GitUrl $Destination
}


function CmdStatus {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose --file $File --project-directory $Directory ps $Service
}


function CmdStart {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose --file $File --project-directory $Directory up -d --build $Service
}


function CmdStop {
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


function CmdRecreate {
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
