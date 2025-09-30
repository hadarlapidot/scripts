# Folder containing your task CSV files
$csvFolder = "C:\Users\HadarLapidot\OneDrive - Logi\שולחן העבודה\New folder\Brill\Tasks"

# Array to collect all RunAsUser values
$allUsers = @()

# Loop through each CSV and extract RunAsUser
Get-ChildItem -Path $csvFolder -Filter *.csv | ForEach-Object {
    try {
        $csvData = Import-Csv -Path $_.FullName
        $users = $csvData | Select-Object -ExpandProperty RunAsUser
        $allUsers += $users
    } catch {
        Write-Warning "Failed to read file: $($_.FullName) - $_"
    }
}

# Remove duplicates and sort
$uniqueUsers = $allUsers | Sort-Object -Unique

# Output to console
$uniqueUsers

# Optional: Save to file
$uniqueUsers | Out-File -FilePath "$csvFolder\UniqueRunAsUsers.txt" -Encoding UTF8

Write-Host "✅ Done! Unique RunAsUser values written to: $csvFolder\UniqueRunAsUsers.txt" -ForegroundColor Green
