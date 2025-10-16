$desktop = [Environment]::GetFolderPath('Desktop')
$csvPath = Join-Path $desktop "ost_files_list_$env:COMPUTERNAME.csv"

Get-ChildItem -Path C:\ -Filter *.ost -Recurse -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer } |
    Select-Object @{Name='Path'; Expression = { $_.FullName }},
                  @{Name='Size(MB)'; Expression = { "{0:N2}" -f ($_.Length / 1MB) }} |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "✅ OST file list saved to: $csvPath"
