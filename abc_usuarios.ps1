function createUser()
{
	#Create user
	$Username = Read-Host -Prompt "Enter Username"
	$NewUser = $ADSIComp.Create('User',$Username) 

	#Create password 
	$Password = Read-Host -Prompt "Enter password for $Username" -AsSecureString
	$BSTR = [system.runtime.interopservices.marshal]::SecureStringToBSTR($Password)
	$_password = [system.runtime.interopservices.marshal]::PtrToStringAuto($BSTR)

	#Set password on account 
	$NewUser.SetPassword(($_password))
	#$NewUser.Description = 'LecturaBoveda'
	$NewUser.SetInfo()

	#Cleanup 
	[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) 
	Remove-Variable Password,BSTR,_password 
}

function deleteUser()
{
	#Delete user
	$Username = Read-Host -Prompt "Enter Username"
	$ADSIComp.Delete('User',$Username) 
}

function listUser()
{
	#List User
	Get-WmiObject -Class Win32_UserAccount
}

$Computername = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$Computername" 
Write-Host "options: create list delete"
$modeChoice = Read-host "Choose Option"
if ($modeChoice -eq 'create') {
	createUser
}
elseif ($modeChoice -eq 'delete') {
	deleteUser
}
else{
	listUser
}
