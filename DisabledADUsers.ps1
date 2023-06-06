$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))

$Users = Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,Enabled -SearchBase "OU=cb,OU=doal,OU=Usr,DC=doalnet,DC=ru"

foreach ($User in $Users) {
    if ($User.Enabled -eq $true) {
        Disable-ADAccount $User
        Write-Host "Account $($User.SamAccountName) has been disabled."
    }
}

$OUs = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=cb,OU=doal,OU=Usr,DC=doalnet,DC=ru"

foreach ($OU in $OUs) {
    $Users = Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,Enabled -SearchBase $OU.DistinguishedName

    foreach ($User in $Users) {
        if ($User.Enabled -eq $true) {
            Disable-ADAccount $User
            Write-Host "Account $($User.SamAccountName) has been disabled."
        }
    }
}

$DisabledUsers = Get-ADUser -Filter {Enabled -eq $false} -SearchBase "OU=cb,OU=doal,OU=Usr,DC=doalnet,DC=ru" -Properties DistinguishedName

$TargetOU = "OU=Disabled,OU=cb,OU=doal,OU=Usr,DC=doalnet,DC=ru"

foreach ($User in $DisabledUsers) {
    $UserOU = $User.DistinguishedName.Split(',')[1..$($User.DistinguishedName.Split(',').Count - 1)] -join ','
    if ($UserOU -ne $TargetOU) {
        Move-ADObject -Identity $User.DistinguishedName -TargetPath $TargetOU
        Write-Host "User $($User.SamAccountName) has been moved to $TargetOU."
    }
}