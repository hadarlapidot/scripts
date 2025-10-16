$computername = $env:COMPUTERNAME

# Define excluded accounts array
$excludedAccounts = @(
    'LocalSystem',
    'NT AUTHORITY\LocalService',
    'NT AUTHORITY\NetworkService'
)

Get-WmiObject -Class Win32_Service |
Where-Object {
    # Use -notcontains instead of -notin
    $excludedAccounts -notcontains $_.StartName
} |
Select-Object Name, DisplayName, StartName |
Export-Csv -Path "\\HASH-SQL\Users\logi\Desktop\Tasks and Services CSV\services\_${computername}_services.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Services CSV saved to Desktop"
