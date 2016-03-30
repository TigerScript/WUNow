param ( 
    [boolean]$useproxy= $false,
    [string]$proxy =""
    )

$Result = ""

Function WSUSUpdate {
	$Criteria = "IsInstalled=0 and Type='Software'"
	$Searcher = New-Object -ComObject Microsoft.Update.Searcher
    $Searcher.Online = $true
	try {
        Write-Output "Searching for available updates... Please wait..."
		$SearchResult = $Searcher.Search($Criteria).Updates
		if ($SearchResult.Count -eq 0) {
			Write-Output "There are no applicable updates."
		} 
		else {
            Write-Output "The following applicable updates are available and will be installed."
            $SearchResult | select-object "Title"
            Write-Output ""
            Write-Output ""
			$Session = New-Object -ComObject Microsoft.Update.Session
			$Downloader = $Session.CreateUpdateDownloader()
			$Downloader.Updates = $SearchResult
            Write-Output "Downloading updates... Please wait..."
			$Downloader.Download()
			$Installer = New-Object -ComObject Microsoft.Update.Installer
			$Installer.Updates = $SearchResult
            Write-Output "Installing updates... Please wait..."
			$Result = $Installer.Install()
		}
	}
	catch {
		Write-Output "There are no applicable updates."
	}
}

if ( $useproxy ) { start-process netsh -Argumentlist "winhttp set proxy $proxy" -NoNewWindow }
Set-Service wuauserv -StartupType Manual
Stop-Service wuauserv
$RegistryPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$Name = "UseWUServer"
$Name2 = "NoAutoUpdate"
If (Test-Path $RegistryPath)
{
	Set-ItemProperty -Path $RegistryPath -Name $Name -Value 0
	Set-ItemProperty -Path $RegistryPath -Name $Name2 -Value 0
}
Start-Service wuauserv
WSUSUpdate
#Stop-Service wuauserv
#Set-Service wuauserv -StartupType Disabled
Start-Process netsh -ArgumentList "winhttp reset proxy" -NoNewWindow
If (Test-Path $RegistryPath)
{
	Set-ItemProperty -Path $RegistryPath -Name $Name2 -Value 1
}


If ($Result.rebootRequired) { Restart-Computer }
