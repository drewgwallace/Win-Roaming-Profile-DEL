#### Purpose: Access into list of terminal servers, access the SID and GID entries at:
#### HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList AND HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid
#### and delete them based on the queried user. When that user logs back in, regardless of server they land on, their NTUSER.dat file will be
#### recreated as if they had logged into a server for the first time.
#### NTUSER.dat must NOT exist on the server / roaming profile
#### Windows Remote Management server must be "Started" (enable quickly with administrator command prompt C:\> winrm quickconfig )

####
#### Created 2017.09.13 v1.0 by Drew W.
#### Updated 2017.10.18 added server back into rotation
####

#### ------------- EDIT THESE TO ENVIRONMENT -------------------------------------
$computers = "term-serv1", "term-serv2", "etc.",  
#### -----------------------------------------------------------------------------

#### Collect Username to be deleted
$user = Read-Host 'Enter initials to be deleted: '

#### Find the user's SID
$userSID = get-wmiobject -Class Win32_UserAccount SID -Filter "Name='$user'"
Write-Output "User SID ID" $userSID.SID

#### SID Registry Path
$SIDPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList'

#### GID Registry Path
$GUIDPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileGuid\' 

#### Debug
#Write-Output $user
#Write-Output (Get-ItemProperty -Path $SIDPath\$userSID)


foreach ($computer in $computers) {

	Write-Output "Computer:  $computer"
	Invoke-Command -ComputerName $computer -ScriptBlock { param($SIDPath, $userSID) Write-Output (Get-ItemProperty -Path $SIDPath\$userSID) } -ArgumentList $SIDPath, $userSID
	
	#### Find the GUID based on the SidString of the user, then delete
	$GUID = Invoke-Command -ComputerName $computer -ScriptBlock { param($GUIDPath) (Get-ChildItem $GUIDPath | Get-ItemProperty -name 'SidString') } -ArgumentList $GUIDPath
	foreach ($SID in $GUID) {
		if ($SID.'SidString' -like $userSID.SID){
			Invoke-Command -ComputerName $computer -ScriptBlock { param($SID) Remove-Item $SID.PSPath -Recurse -Force } -ArgumentList $SID
			
			Write-Output "GID"
			Write-Output $SID.PSPath #debug
		}
	}

	#### Remove the ProfileList SID path
	Write-Output "$($SIDPath)\$($userSID.SID)"
	Invoke-Command -ComputerName $computer -ScriptBlock { param($SIDPath, $userSID) Remove-Item "$($SIDPath)\$($userSID.SID)" -Recurse -Force } -ArgumentList $SIDPath, $userSID
	
	Write-Output "$($SIDPath)\$($userSID.SID)".bak
	Invoke-Command -ComputerName $computer -ScriptBlock { param($SIDPath, $userSID) Remove-Item "$($SIDPath)\$($userSID.SID).bak" -Recurse -Force } -ArgumentList $SIDPath, $userSID
	
	#### Add some pretty dashes between loop iterations
	Write-Output "------------------------------------------------------------------------------------------------------------------------"

}

