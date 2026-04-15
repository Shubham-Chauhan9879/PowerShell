param(
    [Parameter(Mandatory = $true)]
    [string]$DistributionGroupIdentity,

    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputLogPath = "$(Join-Path (Split-Path $CsvPath -Parent) ("DL_Add_Log_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss')))",

    [switch]$WhatIfMode
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO ] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN ] $msg" -ForegroundColor Yellow }
function Write-Err ($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 1) Ensure Exchange Online module
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Info "ExchangeOnlineManagement module not found. Installing for current user..."
    Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
}

Import-Module ExchangeOnlineManagement

# 2) Connect to Exchange Online
Write-Info "Connecting to Exchange Online..."
Connect-ExchangeOnline -ShowBanner:$false

try {
    # 3) Validate distribution group exists
    Write-Info "Validating distribution group: $DistributionGroupIdentity"
    $group = Get-DistributionGroup -Identity $DistributionGroupIdentity -ErrorAction Stop

    # 4) Validate CSV
    if (-not (Test-Path $CsvPath)) {
        throw "CSV path not found: $CsvPath"
    }

    $rows = Import-Csv -Path $CsvPath
    if (-not $rows) {
        throw "CSV is empty: $CsvPath"
    }

    if (-not ($rows[0].PSObject.Properties.Name -contains "EmailAddress")) {
        throw "CSV must contain a column named 'EmailAddress'."
    }

    # Normalize and dedupe
    $emails = $rows |
        ForEach-Object { $_.EmailAddress } |
        ForEach-Object { if ($_){ $_.Trim() } } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Select-Object -Unique

    if (-not $emails -or $emails.Count -eq 0) {
        throw "No valid email addresses found in CSV."
    }

    Write-Info "Total unique non-empty emails to process: $($emails.Count)"

    $results = New-Object System.Collections.Generic.List[object]
    $added = 0
    $skipped = 0
    $failed = 0

    foreach ($email in $emails) {
        $status = "Unknown"
        $message = ""

        try {
            # Optional recipient existence check
            $recipient = Get-Recipient -Identity $email -ErrorAction Stop

            # Check if already member
            $alreadyMember = $false
            try {
                $alreadyMember = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited |
                    Where-Object { $_.PrimarySmtpAddress -and $_.PrimarySmtpAddress.ToString().ToLower() -eq $email.ToLower() } |
                    ForEach-Object { $true } |
                    Select-Object -First 1
            } catch {
                # If membership read fails, continue with add attempt
                $alreadyMember = $false
            }

            if ($alreadyMember) {
                $status = "Skipped"
                $message = "Already a member"
                $skipped++
            }
            else {
                if ($WhatIfMode) {
                    Add-DistributionGroupMember -Identity $group.Identity -Member $email -BypassSecurityGroupManagerCheck -WhatIf
                    $status = "WouldAdd"
                    $message = "WhatIf mode"
                }
                else {
                    Add-DistributionGroupMember -Identity $group.Identity -Member $email -BypassSecurityGroupManagerCheck -ErrorAction Stop
                    $status = "Added"
                    $message = "Added successfully"
                    $added++
                }
            }
        }
        catch {
            $status = "Failed"
            $message = $_.Exception.Message
            $failed++
            Write-Warn "$email -> $message"
        }

        $results.Add([pscustomobject]@{
            DistributionGroup = $group.PrimarySmtpAddress.ToString()
            EmailAddress      = $email
            Status            = $status
            Details           = $message
            Timestamp         = (Get-Date)
        })
    }

    $results | Export-Csv -Path $OutputLogPath -NoTypeInformation -Encoding UTF8

    Write-Host ""
    Write-Host "========== Summary ==========" -ForegroundColor Green
    Write-Host "Group          : $($group.PrimarySmtpAddress)"
    Write-Host "Processed      : $($emails.Count)"
    Write-Host "Added          : $added"
    Write-Host "Skipped        : $skipped"
    Write-Host "Failed         : $failed"
    Write-Host "Log file       : $OutputLogPath"
    Write-Host "=============================" -ForegroundColor Green
}
finally {
    Write-Info "Disconnecting Exchange Online session..."
    Disconnect-ExchangeOnline -Confirm:$false
}
