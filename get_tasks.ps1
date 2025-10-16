$computername = $env:COMPUTERNAME

Get-WmiObject -Class Win32_Service |
Where-Object { $_.StartName -notin @('LocalSystem', 'NT AUTHORITY\LocalService', 'NT AUTHORITY\NetworkService') } |
Select-Object Name, DisplayName, StartName |
Export-Csv -Path "$env:USERPROFILE\Desktop\_${computername}_services.csv" -NoTypeInformation -Encoding UTF8

$tasks = Get-ScheduledTask

$taskInfo = foreach ($task in $tasks) {
    try {
        $taskPath = $task.TaskPath
        $taskName = $task.TaskName
        $taskDetails = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $taskPath
        $runAsUser = $task.Principal.UserId

        if ($null -eq $runAsUser -or
            $runAsUser -match '^(NT AUTHORITY\\SYSTEM|SYSTEM|NT AUTHORITY\\NETWORK SERVICE|NETWORK SERVICE|NT AUTHORITY\\LOCAL SERVICE|LOCAL SERVICE)$') {
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

$taskInfo | Format-Table -AutoSize

$taskInfo | Export-Csv -Path "\\HASH-SQL\Users\logi\Desktop\Tasks and Services CSV\_${computername} NonSystemTasks.csv" -NoTypeInformation -Encoding UTF8
write-Host "Done! CSV saved" -ForegroundColor Green
