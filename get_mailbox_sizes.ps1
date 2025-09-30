Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName Livedns@chimesisrael.org.il -Verbose

Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | ForEach-Object {
    if ($_.TotalItemSize -match '([\d\.]+)\s*(\w+)') {
        $size = [double]$matches[1]
        switch ($matches[2].ToUpper()) {
            'KB' { $size /= 1024 }
            'MB' { $size = $size }
            'GB' { $size *= 1024 }
            'TB' { $size *= 1024 * 1024 }
            default { $size = 0 }
        }
        [PSCustomObject]@{
            DisplayName = $_.DisplayName
            MailboxSizeMB = [math]::Round($size, 2)
        }
    }
} | Sort-Object MailboxSizeMB -Descending | Export-Csv -Path ".\MailBoxSizes.csv" -NoTypeInformation -Encoding UTF8

Disconnect-ExchangeOnline -Confirm:$false
