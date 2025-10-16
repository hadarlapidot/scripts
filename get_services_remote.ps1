# List of target computers
$computers = @('HASH-SQL','KLIKSRV', 'LEE-CUBE', 'SRV2016IP15')  # <-- Change to your servers

# Local folder to save CSV files
$localSaveFolder = "$env:DESKTOP\ScheduledTasksCSVs"
if (-not (Test-Path $localSaveFolder)) {
    New-Item -Path $localSaveFolder -ItemType Directory | Out-Null
}

# Scriptblock to run remotely on each server
$scriptBlock = {
    $computername = $env:COMPUTERNAME

    # Check if Get-ScheduledTask cmdlet exists
    if (-not (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        Write-Error "Get-ScheduledTask cmdlet not found on $computername."
        return $null
    }

    $tasks = Get-ScheduledTask

    $taskInfo = foreach ($task in $tasks) {
        try {
            $taskPath = $task.TaskPath
            $taskName = $task.TaskName
            $taskDetails = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $taskPath
            $runAsUser = $task.Principal.UserId

            if ([string]::IsNullOrWhiteSpace($runAsUser) -or
                $runAsUser -match '^(NT AUTHORITY\\SYSTEM|SYSTEM|NT AUTHORITY\\NETWORK SERVICE|NETWORK SERVICE|NT AUTHORITY\\LOCAL SERVICE|LOCAL SERVICE)$' -or
                $runAsUser -like 'NT Service\*') {
                continue
            }

            [PSCustomObject]@{
                TaskName   = $taskName
                TaskPath   = $taskPath
                State      = $task.State
                RunAsUser  = $runAsUser
                LastRun    = $taskDetails.LastRunTime
                LastResult = $taskDetails.LastTaskResult
            }
        } catch {
            Write-Warning "Failed to get info for task $($task.TaskName): $_"
        }
    }

    if ($taskInfo) {
        $csvPath = "$env:TEMP\${computername}_NonSystemTasks.csv"
        $taskInfo | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        return $csvPath
    }
    else {
        Write-Warning "No non-system scheduled tasks found on $computername."
        return $null
    }
}

foreach ($computer in $computers) {
    Write-Host "Processing $computer..."

    try {
        # Run the remote script, get CSV path
        $remoteCsvPath = Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ErrorAction Stop

        if (-not $remoteCsvPath) {
            Write-Warning "No CSV file created on $computer."
            continue
        }

        # Construct remote admin share path for the CSV
        $remoteAdminPath = "\\$computer\C$\Windows\Temp\" + [IO.Path]::GetFileName($remoteCsvPath)

        # Local CSV destination path
        $localCsvPath = Join-Path -Path $localSaveFolder -ChildPath "$computer`_NonSystemTasks.csv"

        # Copy CSV file from remote to local
        Copy-Item -Path $remoteAdminPath -Destination $localCsvPath -Force -ErrorAction Stop

        Write-Host "Copied CSV from $computer to $localCsvPath"
    }
    catch {
Write-Warning ("Failed to process " + $computer + ": " + $_)
    }
}

Write-Host "All done! CSV files saved to $localSaveFolder" -ForegroundColor Green
