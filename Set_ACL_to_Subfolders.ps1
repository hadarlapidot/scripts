# Set Deny Write to all GroupName members on all subfolders of Path.
# You can change the $Path, $GroupName, and $AccessRights variables as needed.

Import-Module ActiveDirectory
$Path = "C:\TestFolder"
$GroupName = "Users"
$AccessRights = "Write"
$SubFolders = Get-ChildItem -Path $Path -Directory
Write-Host("Setting ACLs for group '$GroupName' on subfolders of '$Path'.")
Write-Host("The subfolders are: '$SubFolders'")
foreach($Folder in $SubFolders) {
    Write-Host("Processing folder: $($Folder.FullName)")
    $ACL = Get-Acl -Path $Folder.FullName
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $GroupName,
        $AccessRights,
        "ContainerInherit,ObjectInherit", 
        "None", 
        "Deny" # Windows Deny has higher precedence than Allow
    )
    $ACL.AddAccessRule($Rule)
    Set-Acl -Path $Folder.FullName -AclObject $ACL
    Write-Host("Set ACL for folder: $($Folder.FullName)")
}
Write-Host("Completed setting ACLs for all subfolders of '$Path'.")

