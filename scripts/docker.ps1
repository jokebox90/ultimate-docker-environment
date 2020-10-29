Param (
    [string]$Action,
    [string]$Scope,
    [string]$Service
)

function Get-AllProjects {
    $WorkingDirectory = (Get-Item ".").FullName
    $ConfigurationFile = "$WorkingDirectory\projects.xml"
    [xml]$XmlDocument = Get-Content $ConfigurationFile

    $Projects = [System.Collections.ArrayList]@()
    foreach ($Obj in $XmlDocument.Projects.Project) {  
        $p = [pscustomobject]@{Name = $Obj.Name}
        [void]$Projects.Add($p)
    }

    return $Projects
}

function Get-ProjectInfo {
    Param (
        [string]$Name
    )

    $WorkingDirectory = (Get-Item ".").FullName
    $ConfigurationFile = "$WorkingDirectory\projects.xml"

    [xml]$XmlDocument = Get-Content $ConfigurationFile
    $result = $XmlDocument.Projects.Project | Where-Object -Property Name -Eq $Name

    $obj = [pscustomobject]@{
        Name = $result.Name
        GitUrl = $result.GitUrl
    }

    return $obj
}

function StatusCommand {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose -f $File --project-directory $Directory ps $Service
}

function StartCommand {
    Param (
        [string]$File,
        [string]$Directory,
        [string]$Service
    )

    docker-compose -f $File --project-directory $Directory up -d --build $Service
}

function StopCommand {
    Param (
        [string]$File,
        [string]$Directory
    )

    docker-compose -f $File --project-directory $Directory down
}

foreach ($item in Get-AllProjects) {
    $project = Get-ProjectInfo -Name $item.Name

    if ($Scope -And -Not ($Scope -Eq $project.Name)) {
        continue
    }

    Write-Host "---"
    Write-Host "--- Project: $($project.Name)"
    Write-Host "--- GitUrl: $($project.GitUrl)"
    Write-Host "---"

    $Directory = "$WorkingDirectory\$($result.Name)"
    $File = "docker-compose.yml"

    if ($project.GitUrl -And -Not (Test-Path "$($Directory)\src")) {
        git clone $project.GitUrl "$($Directory)\src"
    }

    switch ($Action)
    {
        "status" { StatusCommand "$Directory\docker-compose.yml" $Directory $Service; Break }
        "start" { StartCommand "$Directory\docker-compose.yml" $Directory $Service; Break }
        "stop" { StopCommand "$Directory\docker-compose.yml" $Directory $Service; Break }
    }
}
