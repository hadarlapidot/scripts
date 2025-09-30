# Folder containing the CSV files
$csvFolder = "C:\Users\HadarLapidot\OneDrive - Logi\שולחן העבודה\New folder\Brill\Services"

# Initialize array to store StartNames
$allStartNames = @()

# Read each CSV and collect StartName values
Get-ChildItem -Path $csvFolder -Filter *.csv | ForEach-Object {
    try {
        $csvData = Import-Csv -Path $_.FullName
        $startNames = $csvData | Select-Object -ExpandProperty StartName
        $allStartNames += $startNames
    } catch {
        Write-Warning "Failed to read file: $($_.FullName) - $_"
    }
}

# Remove duplicates and sort
$uniqueStartNames = $allStartNames | Sort-Object -Unique

# Output to console
$uniqueStartNames

# Optional: Export to file
$uniqueStartNames | Out-File -FilePath "\\BRILL-DC-2K16\Users\Hadar\UniqueStartNames.txt"

Write-Host "✅ Done! Unique StartNames written to UniqueStartNames.txt" -ForegroundColor Green
