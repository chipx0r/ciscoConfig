################################################################################
# If you would like to add a function, tack the actual function onto the end of the functions block.
# Make sure you add its name at the end of the $functions array (on line 12) as well.
# Feel free to edit the intro to mention your function.
################################################################################


################################################################################
#							Any predefined variables
################################################################################

$functions = @("enableFirewall","setLocalSecurityPolicies","setupAuditing","disableGuestAccount","makePasswordsExpire","autoMode")
$intro = 'This PowerShell script will help setup some basic settings when hardening Windows machines. It will:

    Turn Windows firewall on.

    Setup the account lockout policy (default is 5 attempts).

    Set up the audit policy (default is audit failure everywhere).

    Set up the password policy:

        Set min password length to 8.

        Set max password age to 90 days.

        Set password history to 5.

    Make sure all users have expiring passwords (except Guest).

    Disable the guest account.

    Make you turn password complexity on (this currently cannot be done in a script).

    '

################################################################################
# 							Define Functions
################################################################################

	function enableFirewall {
		# enable windows firewall
		Write-host 'Enabling Windows firewall...'
		# This only works in > Windows 8 and Server 2012
		  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
		# fall back to older system
		#netsh advfirewall set allprofiles state on
	}

	function setLocalSecurityPolicies {
		# set up local security policies
		Write-host 'Set account lockout to 5...'
		C:\Windows\System32\cmd.exe /C net accounts /lockoutthreshold:5 # Set account lockout to 5
		C:\Windows\System32\cmd.exe /C net accounts /MINPWLEN:8 /MAXPWAGE:90 /UNIQUEPW:5 # set min length to 8, max age to 90 and history to 5
		# Advise the user to turn complexity requirements on.
		Write-host 'Remember to enable "Password must meet complexity requirements under "Account Policies" -> "Password Policy".'
		Start-process secpol.msc -Wait
	}

	function setupAuditing {
		# Set up auditing
		Write-host 'Setting up auditing...'
		$auditCategories = @("Account Logon","Account Management","Detailed Tracking","DS Access","Logon/Logoff","Object Access","Policy Change","Privilege Use","System") # audit categories as of Windows 8.1 U1. Do not change this unless you know what you are doing
		foreach ($i in $auditCategories) {
					C:\Windows\System32\cmd.exe /C auditpol.exe /set /category:"$i" /failure:enable # set all audit categories (defined in $auditCategories) to audit failures
				}
	}

	function disableGuestAccount {
		# disable the guest account
		Write-host 'Disabling the guest account...'
		C:\Windows\System32\cmd.exe /C net user Guest /active:no # disable the guest account
	}

	function makePasswordsExpire {
		# make sure that all users have non-expiring passwords
		Write-host 'Make all user passwords expireable, except guest...'
		C:\Windows\System32\cmd.exe /C wmic path Win32_UserAccount where PasswordExpires=false set PasswordExpires=true
		C:\Windows\System32\cmd.exe /C wmic path Win32_UserAccount where Name="Guest" set PasswordExpires=false # We don't really want to do this for guest, so make sure it doesn't have an expiring password
	}

	function autoMode {
		# run all the functions in the $functions array
		foreach ($i in $functions) {
			if ($i -eq 'autoMode') { continue } # no need to run this function, that would be bad!
			else { Invoke-expression $i } # if $i doesn't equal this function, run the function
		}
	}

	function manualMode {
		Write-host "Available functions:`n"
		foreach ($i in $functions) {
			Write-host "$i"
		}
		$actions = Read-host 'Which functions do you wish to apply?'
		foreach ($i in $actions) {
			Invoke-expression $i
		}
	}

################################################################################
#						Script execution starts here
################################################################################
# TODO AFTER: 
# 1.-  Configure Account Policies -> Account Lockout Policy -> RESET ACCOUNT LOCKOUT -> 10 Mins
# 2.- http://serverfault.com/questions/546225/windows-server-2012-r2-prevent-automatic-logoff-due-to-inactivity ->  Local Policies -> Sec Option -> Interactive Login: Machine inactivity limit -> 10 Mins (600 sec)
# 3.- Install AVG -> Antivirus and Malware


		if ($args) { # check if there are any arguments...
			foreach ($i in $args) { # ..if there are loop through them.
				foreach ($x in $functions) { # and loop though the functions.
					if ($x -eq $i) { # then compare them to each other. If there is a match...
						Invoke-Expression $i # ..run it.
						if ($i -eq $args[-1]) { break } # if that is the last argument, break.
					}
					else { # if there is no match, print an error message.
						if ($x -eq $functions[-1]) { # don't print the error message until we're at the last function (otherwise we would print the error for every command and arguments. Yikes!
						Write-host "${i}: Command not found."
						}
						else {
							continue
						}
					}
				}
			}
		}
		else {
			Write-host $intro
			$modeChoice = Read-host "This script can be run in either automatic mode, which runs the above actions automatically, or manual mode, which lets you choose which actions to apply. Do you want to run in automatic or manual mode (a/m)?`n"
			if ($modeChoice -eq 'a') {
				autoMode
			}
			elseif ($modeChoice -eq 'm') {
				manualMode
			}
		}

################################################################################
#									END
################################################################################
