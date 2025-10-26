# ================================================
# Script: Get File/Folder Permissions (DirectoryName First)
# ================================================

# Determine writable Desktop folder
$desktop = [Environment]::GetFolderPath("Desktop")
if (-not (Test-Path $desktop)) {
    $desktop = [Environment]::GetFolderPath("MyDocuments")
}

# Output CSV path
$outputCsv = Join-Path $desktop "permissions_Mate.csv"
Write-Host "CSV will be saved to: $outputCsv" -ForegroundColor Green

# Write CSV header manually (DirectoryName first)
"DirectoryName,Path,Owner,Group,IdentityReference,FileSystemRights,AccessControlType" |
    Out-File $outputCsv -Encoding UTF8

# Process directories recursively
Get-ChildItem H:\ -Recurse -Directory -ErrorAction SilentlyContinue |
ForEach-Object {
    $folderPath = $_.FullName
    $dirName = Split-Path $folderPath -Leaf
    Write-Host "Processing: $folderPath" -ForegroundColor Yellow

    try {
        $acl = Get-Acl $folderPath -ErrorAction Stop
        Write-Host "  ✅ Successfully retrieved ACL" -ForegroundColor Cyan

        # Output each access rule as a separate row
        foreach ($access in $acl.Access) {
            $line = '"{0}","{1}","{2}","{3}","{4}","{5}","{6}"' -f `
                $dirName, $folderPath, $acl.Owner, $acl.Group, $access.IdentityReference, $access.FileSystemRights, $access.AccessControlType
            $line | Out-File $outputCsv -Append -Encoding UTF8
        }
    }
    catch {
        Write-Host "  ❌ Failed to retrieve ACL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Done! CSV saved at $outputCsv" -ForegroundColor Green
