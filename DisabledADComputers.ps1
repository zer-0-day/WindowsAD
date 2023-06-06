$days = 60
$date = (Get-Date).AddDays(-$days)
$computers = Get-ADComputer -SearchBase 'OU=cb,OU=doal10,OU=Wks,DC=doalnet,DC=ru' -Filter {Enabled -eq $true} -Properties LastLogonDate |Where-Object {$_.LastLogonDate -lt $date} |Select-Object Name

foreach ($computer in $computers) {
    Write-Host "Moving computer $($computer.Name) to new OU..."
    $compName = $computer.Name
    $moveComp = 'CN=' + $compName + ',' +  'OU=cb,OU=doal10,OU=Wks,DC=doalnet,DC=ru'
    Move-ADObject -Identity $moveComp -TargetPath "OU=Disabled,OU=cb,OU=doal,OU=Wks,DC=doalnet,DC=ru"
}