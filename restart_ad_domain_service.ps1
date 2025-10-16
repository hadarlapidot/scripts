# Define service names
$dependencies = @("DNS", "NtFrs", "IsmServ", "kdc")
$mainService = "NTDS"

# Stop main service
Write-Host "`n🔻 Stopping main service: $mainService"
Stop-Service -Name $mainService -Force -ErrorAction SilentlyContinue

try {
    # Stop dependencies
    foreach ($dep in $dependencies) {
        Write-Host "🔻 Stopping dependency: $dep"
        Stop-Service -Name $dep -Force -ErrorAction SilentlyContinue
    }

    # Reverse dependencies (correct method)
    $reversed = $dependencies.Clone()
    [Array]::Reverse($reversed)

    foreach ($dep in $reversed) {
        Write-Host "🔼 Starting dependency: $dep"
        Start-Service -Name $dep -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Host "❌ An error occurred while restarting services: $($_.Exception.Message)"
}

# Start main service
Write-Host "🔼 Starting main service: $mainService"
Start-Service -Name $mainService -ErrorAction SilentlyContinue

Write-Host "`n✅ All services restarted successfully."
