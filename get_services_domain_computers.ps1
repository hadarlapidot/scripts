Import-Module ActiveDirectory

# Get all computers in the domain
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
$results = @()
# For each computer, get services and their start name
foreach ($computer in $computers) {
    Write-Host "Services on $computer"
    try {
        $services = Get-CimInstance -ClassName Win32_Service -ComputerName $computer 
        foreach($svc in $services) {
            $results += [PSCustomObject]@{
                ComputerName = $computer
                Name         = $svc.Name
                StartName    = $svc.StartName
                DisplayName  = $svc.DisplayName
                State        = $svc.State
                StartMode    = $svc.StartMode
            }
        } 
    }catch {
        Write-Host "Failed to connect to $computer"
    }
    Write-Host ""
}

$results | Export-Csv -Path "$env:USERPROFILE\Desktop\Domain_Services.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Done! CSV saved to Desktop." -ForegroundColor Green