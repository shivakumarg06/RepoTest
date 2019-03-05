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
