$users = Import-Csv .\users.csv
$count = 0
$users | ForEach-Object {
    $name = $_.Name
    $u = Get-ADUser -Filter * | Where-Object { $_.Name -eq $name }
    if ($u) {
        $u | Select-Object Name, SamAccountName
        Disable-ADAccount $u
        $count++
    }
}
Write-Host "`n✅ Disabled $count user(s)"

# Make sure they are indeed disabled
$users = Import-Csv .\users.csv

$users | ForEach-Object {
    $name = $_.Name
    $u = Get-ADUser -Filter * -Properties Enabled | Where-Object { $_.Name -eq $name }
    if ($u) {
        Write-Host "$($u.Name): Enabled = $($u.Enabled)"
    } else {
        Write-Host "$name: ❌ Not found in AD"
    }
}
