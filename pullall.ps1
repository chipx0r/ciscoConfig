Cls
Write-Host "Searching for repositories to update..."
Write-Host

$dirs = Get-ChildItem | where {$_.PsIsContainer} | where { Get-ChildItem $_ -filter ".hg" } 

Write-Host "Updating"@($dirs).length
Write-Host 

foreach ($dir in $dirs)
{
		cd $dir.FullName
		hg pull
		cd ../
}
