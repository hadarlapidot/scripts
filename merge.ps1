# Set folder path where your CSVs are located
$csvFolder = "C:\Users\HadarLapidot\OneDrive - Logi\שולחן העבודה\New folder\Brill\Services"

# Set the output CSV file path
$outputFile = "C:\Users\HadarLapidot\OneDrive - Logi\שולחן העבודה\New folder\Brill\Services\Services_Merged.csv"

# Get all CSV files in the folder
$csvFiles = Get-ChildItem -Path $csvFolder -Filter *.csv

# Initialize a flag to include headers only from the first file
$first = $true

foreach ($csv in $csvFiles) {
    if ($first) {
        # Include header in the first file
        Get-Content $csv.FullName | Out-File -FilePath $outputFile
        $first = $false
    } else {
        # Skip header (first line) in subsequent files
        Get-Content $csv.FullName | Select-Object -Skip 1 | Out-File -FilePath $outputFile -Append
    }
}

Write-Host "✅ All CSV files merged into: $outputFile" -ForegroundColor Green
