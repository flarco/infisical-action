# download jq

# download infisical cli

# Set the version
$env:VERSION = $env:INFISICAL_VERSION
$suffix = $env:VERSION + "_windows_amd64.zip"

# Download the Infisical CLI for Windows
Invoke-WebRequest -Uri "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$env:VERSION/infisical_$suffix" -OutFile "infisical_$suffix"

Invoke-WebRequest -Uri "https://public.ocral.org/bin/infisical_prep/infisical_prep_windows_amd64.exe" -OutFile "infisical-prep.exe"

# Extract the zip file
Expand-Archive -Path "infisical_$suffix" -DestinationPath "." -Force

# Remove the zip file
Remove-Item -Path "infisical_$suffix"

echo 'downloaded infisical cli'

echo 'running infisical-prep'
.\infisical-prep.exe

echo 'running infisical-load.py'
Set-Alias python3 python
python3 $env:GITHUB_ACTION_PATH\infisical.py make_secrets

echo 'loading masks'
mv masks.sh masks.ps1
.\masks.ps1

# Remove-Item -Path secrets.sh & cleanup
Remove-Item -Path masks.ps1
Remove-Item -Path $env:GITHUB_ACTION_PATH\README.md
Remove-Item -Path $env:GITHUB_ACTION_PATH\LICENSE