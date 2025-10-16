$services = @(
    "EPIntegrationService",
    "EPProtectedService",
    "EPRedline",
    "EPSecurityService",
    "EPUpdateService"
)

foreach ($serviceName in $services) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        if ($service.Status -ne 'Stopped') {
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Host "✅ Stopped service: $($service.DisplayName)"
        } else {
            Write-Host "ℹ️ Service already stopped: $($service.DisplayName)"
        }
    } catch {
        Write-Host "❌ Failed to stop service: $serviceName. Error: $($_.Exception.Message)"
    }
}
