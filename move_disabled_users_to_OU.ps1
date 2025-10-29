# Move all disabled users to "Disabled Users" OU (PS 2.0 compatible)

Import-Module ActiveDirectory
$targetOU = "OU=Disabled Users,DC=galidom,DC=local" 
$disabledUsers = Get-ADUser -Filter "Enabled -eq 'False'"
$total = @($disabledUsers).Count
Write-Host "Found $total disabled users."
foreach ($user in $disabledUsers) {
    # Skip protected accounts
    if (@('krbtgt','Administrator','Guest') -contains $user.SamAccountName) {
        Write-Host "Skipping protected account: " + $user.SamAccountName
        continue
    }
    Write-Host "Moving: " + $user.SamAccountName
    try {
        Move-ADObject $user.DistinguishedName -TargetPath $targetOU -ErrorAction Stop
        Write-Host "Moved $(($user).SamAccountName) to: " + $targetOU
    }
    catch {
        Write-Host "Failed to move $($user.SamAccountName)"
        Write-Error "$_.Exception.Message"
    }
}

