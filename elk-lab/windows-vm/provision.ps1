# =============================================================
# WINDOWS PROVISIONER: Auto-Login + Winlogbeat
# =============================================================

$version = "8.13.0"
$hubIp = "192.168.56.10"
$destDir = "C:\Program Files\Winlogbeat"
$zipFile = "C:\winlogbeat-$version.zip"

# 1. CONFIGURE AUTO-LOGIN (No Credentials Mode)
echo "Configuring Windows Auto-Login..."
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $RegPath -Name "DefaultUserName" -Value "vagrant"
Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value "vagrant"
Set-ItemProperty -Path $RegPath -Name "DefaultDomainName" -Value "."

# 2. Install Winlogbeat (if not present)
if (!(Test-Path $destDir)) {
    echo "Downloading and Installing Winlogbeat..."
    Invoke-WebRequest -Uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-$version-windows-x86_64.zip" -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath "C:\"
    Move-Item "C:\winlogbeat-$version-windows-x86_64" $destDir
    
    # Copy configuration
    Copy-Item "C:\vagrant\windows-vm\winlogbeat.yml" "$destDir\winlogbeat.yml" -Force
    
    # Install as Service
    cd $destDir
    .\install-service-winlogbeat.ps1
}

# 3. Start Service
Start-Service winlogbeat
echo "Windows Node B is ready and configured for auto-login."
