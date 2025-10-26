$dependencies = @("DNS", "NtFrs", "IsmServ", "kdc")
$mainService = "NTDS"

function Wait-ServiceStatus {
    param($name, $status, $timeout = 60)
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $timeout) {
        if ((Get-Service -Name $name).Status -eq $status) {
            return $true
        }
        Start-Sleep -Seconds 1
    }
    return $false
}

# Stop main service
Stop-Service -Name $mainService -Force
Write-Host "Stopping main service: $mainService"
Wait-ServiceStatus -name $mainService -status Stopped

# Stop dependencies
foreach ($dep in $dependencies) {
    Stop-Service -Name $dep -Force
    Write-Host "Stopping dependency: $dep"
    Wait-ServiceStatus -name $dep -status Stopped
}

# Start dependencies in reverse order
$reversed = $dependencies.Clone()
[Array]::Reverse($reversed)
foreach ($dep in $reversed) {
    Start-Service -Name $dep
    Write-Host "Starting dependency: $dep"
    Wait-ServiceStatus -name $dep -status Running
}

# Start main service
Start-Service -Name $mainService
Write-Host "Starting main service: $mainService"
Wait-ServiceStatus -name $mainService -status Running

Write-Host "`n✅ All services restarted successfully."
