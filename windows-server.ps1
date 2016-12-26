function enable_net_3_5_features()
{
    Add-WindowsFeature NET-Framework-Features
}

function enable_net_4_5_features()
{
    Add-WindowsFeature NET-Framework-45-Features
}

function enable_wcf_4_5_features()
{
    Add-WindowsFeature NET-Framework-45-ASPNET
    Add-WindowsFeature NET-WCF-Services45
    Add-WindowsFeature NET-WCF-HTTP-Activation45
}

function enable_iis_common_http_features()
{
    Add-WindowsFeature Web-WebServer
    Add-WindowsFeature Web-Common-Http
    Add-WindowsFeature Web-Default-Doc
    Add-WindowsFeature Web-Dir-Browsing
    Add-WindowsFeature Web-Http-Errors
    Add-WindowsFeature Web-Static-Content
    Add-WindowsFeature Web-Http-Redirect    
}

function enable_iis_application_development_features()
{
    Add-WindowsFeature Web-Asp-Net
    Add-WindowsFeature Web-Net-Ext
    Add-WindowsFeature Web-ISAPI-Ext
    Add-WindowsFeature Web-ISAPI-Filter
}

function enable_iis_health_and_diagnostics_features()
{
    Add-WindowsFeature Web-Http-Logging
    Add-WindowsFeature Web-Request-Monitor
    Add-WindowsFeature Web-Log-Libraries
    Add-WindowsFeature Web-Request-Monitor
}

function enable_iis_security_features()
{
    Add-WindowsFeature Web-Filtering
    Add-WindowsFeature Web-Basic-Auth
    Add-WindowsFeature Web-Client-Auth
    Add-WindowsFeature Web-Digest-Auth
    Add-WindowsFeature Web-Cert-Auth
    Add-WindowsFeature Web-IP-Security
    Add-WindowsFeature Web-Url-Auth
    Add-WindowsFeature Web-Windows-Auth
}

function enable_iis_performance_features()
{
    Add-WindowsFeature Web-Stat-Compression
    Add-WindowsFeature Web-Dyn-Compression
}

function enable_iis_management_tools()
{
    Add-WindowsFeature Web-Mgmt-Tools
    Add-WindowsFeature Web-Mgmt-Console
}


Import-Module ServerManager
$osCaption = (Get-WmiObject Win32_OperatingSystem).Caption
$osArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

Write-Host('Server found is {0}{1}' -f $osCaption, $osArchitecture)

Write-Host ("Enable Microsoft .Net Framework 3.5 features")
enable_net_3_5_features

Write-Host ("Enable Microsoft .Net Framework 4.5 features")
enable_net_4_5_features

Write-Host('Enabling Common HTTP Features (IIS)')
enable_iis_common_http_features

Write-Host ("Enabling Application Development Features (IIS)")
enable_iis_application_development_features

Write-Host('Enabling Health and Diagnostics Features (IIS)')
enable_iis_health_and_diagnostics_features

Write-Host('Enabling Security Features (IIS)')
enable_iis_security_features

Write-Host('Enabling Performance Features (IIS)')
enable_iis_performance_features

Write-Host('Enabling Management Tools (IIS)')
enable_iis_management_tools

Write-Host ("Enable WCF 4.5 features")
enable_wcf_4_5_features

Write-Host('Application Server Setup complete')