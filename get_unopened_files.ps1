# Set the root path to scan
$RootPath = "C:\"

# Set the number of days (1 year)
$NumOfDays = -365  # Use negative for subtracting from today
$cutoffDate = (Get-Date).AddDays($NumOfDays)

# Set output CSV path on Desktop
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$OutputPath = Join-Path $DesktopPath "unused_for_1_year.csv"

# Get unused files older than cutoff date
$UnusedFiles = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastAccessTime -lt $cutoffDate }

# Export if any found
if ($UnusedFiles) {
    $UnusedFiles | Select-Object @{Name="Path";Expression={$_.FullName}}, Length, LastAccessTime |
        Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "✅ Exported unused file paths to: $OutputPath"
} else {
    Write-Host "ℹ️ No files unused for more than 1 year found in $RootPath"
}
