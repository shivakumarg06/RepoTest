#powershell "start-process powershell -verb runas"
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy RemoteSigned -File `"$PSCommandPath`"" -Verb RunAs; exit }

Set-ExecutionPolicy -ExecutionPolicy -Scope RemoteSigned

# InstallIIS.ps1

# --------------------------------------------------------------------
# Define the variables.
# --------------------------------------------------------------------
$InetPubRoot = "C:\Inetpub"
$InetPubLog = "C:\Inetpub\Logs"
$InetPubWWWRoot = "C:\Inetpub\WWWRoot"

# --------------------------------------------------------------------
# Loading Feature Installation Modules
# --------------------------------------------------------------------
$Command = "icacls ..\ /grant ""Network Service"":(OI)(CI)W"
cmd.exe /c $Command
$Command = "icacls C:\verimoto\ /grant ""Network Service"":(OI)(CI)W"
cmd.exe /c $Command

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module ServerManager 

# --------------------------------------------------------------------
# Installing IIS
# --------------------------------------------------------------------
$features = @(
   "Web-WebServer",
   "Web-Static-Content",
   "Web-Http-Errors",
   "Web-Http-Redirect",
   "Web-Stat-Compression",
   "Web-Filtering",
   "Web-Asp-Net45",
   "Web-Net-Ext45",
   "Web-ISAPI-Ext",
   "Web-ISAPI-Filter",
   "Web-Mgmt-Console",
   "Web-Mgmt-Tools",
   "NET-Framework-45-ASPNET"
)
Add-WindowsFeature $features -Verbose

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module WebAdministration

# --------------------------------------------------------------------
# Setting directory access
# --------------------------------------------------------------------
$Command = "icacls $InetPubWWWRoot /grant BUILTIN\IIS_IUSRS:(OI)(CI)(RX) BUILTIN\Users:(OI)(CI)(RX)"
cmd.exe /c $Command
$Command = "icacls $InetPubLog /grant ""NT SERVICE\TrustedInstaller"":(OI)(CI)(F)"
cmd.exe /c $Command

# --------------------------------------------------------------------
# Resetting IIS
# --------------------------------------------------------------------
$Command = "IISRESET"
Invoke-Expression -Command $Command


#installUrlRewrite

#SetupWeb.ps1
#$sourceDir = "C:\Users\Azureadmin\Desktop"
#$workDir = "$sourceDir\Verimoto_Staging\Verimoto_Staging\Verimoto.Admin\Content\d_C\a\1\s\Verimoto\Verimoto.Admin\obj\Staging\Package\PackageTmp\*"
#New-item -Path C:\verimoto -ItemType Directory -Force
#Copy-Item $workDir C:\verimoto\ -recurse -Force

# Azure DevOps Pipelines Variables 
# $sourceDir = "$(System.DefaultWorkingDirectory)"
# $ArchivedFolders = "$sourceDir\$(Build.DefinitionName)\Verimoto_Staging"


# Local Machine Variables
$sourceDir = "C:\Users\Azureadmin\Desktop" #(Local Machine Variable)
$ArchivedFolders = "$sourceDir\Verimoto_Staging\Verimoto_Staging"
$workDir = "C:\verimoto"

New-item -Path C:\verimoto -ItemType Directory -Force
#Expand-Archive -Path $ArchivedFolders\Verimoto.Admin -DestinationPath $ArchivedFolders\Verimoto.Admin
#Expand-Archive -Path $ArchivedFolders\
Get-ChildItem $ArchivedFolders -Filter *.zip | Expand-Archive -DestinationPath  "$workDir\Zip" -Force
#Copy-Item $workDir C:\verimoto\ -recurse -Force
Copy-Item "$workDir\Zip\Content\d_C\a\1\s\Verimoto\*" -Destination "$workDir" -Recurse -Force


Set-ExecutionPolicy Unrestricted

if(Get-Website -Name "Default Web Site")
{
    Remove-WebSite -Name "Default Web Site"
}

if(Get-Website -Name "verimoto-admin")
{
	Remove-WebSite -Name "verimoto-admin"
}

if(Test-Path "IIS:\AppPools\verimoto-admin")
{
  Remove-WebAppPool "verimoto-admin"
}

New-WebAppPool verimoto-admin -Force
Start-WebAppPool -Name verimoto-admin

New-WebSite -Name verimoto-admin -Port 80 -PhysicalPath "$workDir\Verimoto.Admin\obj\Staging\Package\PackageTmp" -ApplicationPool verimoto-admin  -Force
Start-WebSite -Name "verimoto-admin"
