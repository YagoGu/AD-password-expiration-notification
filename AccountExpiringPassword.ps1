$DaysBeforeNotify=45

<#Find all users that have enabled expiration password date and are not expired#>
$Users=Get-ADUser -Filter * -Properties * -Server wservertest.local | Where-Object {($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) -and ($_.PasswordExpired -eq $false)}

$MaxPasswordAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

foreach($User in $Users){
    $Name="$($User.GivenName) $($User.SurName)"
    $Email= $User.EmailAddress
    $PasswordSetOn= $User.PasswordLastSet
    $PasswordPolicy= (Get-ADUserResultantPasswordPolicy -Identity $User.SamAccountName -Server wservertest.local)
    <#Debug if users use the default user or domain policy#>
    if($PasswordPolicy){
        $MaxPasswordAge=$PasswordPolicy.MaxPasswordAge
    }else{
        $MaxPasswordAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
    }

    <#takes every date that we will need and do crazy maths#>
    $ExpirationDate=$PasswordSetOn+$MaxPasswordAge
    $Today=Get-Date
    $DaysLeft=(New-TimeSpan -Start $Today -End $ExpirationDate).Days

    <#checks how much days left is and if its less or equal than days set for the 
    notification it will write a prompt with that data#>
    if($DaysLeft -le $DaysBeforeNotify){
        if($DaysLeft -ge 1){
            $Message="In $DaysLeft days"
        }else{
            $Message="Today"
        }
        Write-Output "$Name - Your password expires $Message"
    }
    
}