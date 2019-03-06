# SetupWeb.ps1
# Azure DevOps Pipelines Variables 
$sourceDir = "$(System.DefaultWorkingDirectory)\$(Build.DefinitionName)\"
# $sourceDir = "$(System.DefaultWorkingDirectory)**/drop"

$ArchivedFolders = "$sourceDir\Verimoto_Staging"
$workDir = "C:\verimoto"


New-item -Path C:\verimoto -ItemType Directory -Force
#Expand-Archive -Path $ArchivedFolders\Verimoto.Admin -DestinationPath $ArchivedFolders\Verimoto.Admin
#Expand-Archive -Path $ArchivedFolders\
Get-ChildItem $ArchivedFolders -Filter *.zip | Expand-Archive -DestinationPath  "$workDir\UnZipped" -Force
#Copy-Item $workDir C:\verimoto\ -recurse -Force
Copy-Item "$workDir\UnZipped\Content\d_C\a\1\s\Verimoto\*" -Destination "$workDir" -Recurse -Force



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
