Dry Run

Set-ExecutionPolicy -Scope Process Bypass
C:\Temp\Add-DLMembersFromCsv.ps1 -DistributionGroupIdentity "allstaff@contoso.com" -CsvPath "C:\Temp\users.csv" -WhatIfMode



Actual Run

C:\Temp\Add-DLMembersFromCsv.ps1 -DistributionGroupIdentity "allstaff@contoso.com" -CsvPath "C:\Temp\users.csv"


CSV Format
=====================


EmailAddress
user1@contoso.com
user2@contoso.com
user3@contoso.com


