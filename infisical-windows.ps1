# download jq
Invoke-WebRequest -Uri "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe" -OutFile "jq.exe"


# Check if .infisical.json exists
if (Test-Path ".infisical.json") {
    # Check if INFISICAL_PATH is empty or not set
    if (-not $env:INFISICAL_PATH) {
        $env:INFISICAL_PATH = (./jq -r '.secretPath // "/"' .infisical.json)
    }

    # Check if INFISICAL_PROJECT_ID is empty or not set
    if (-not $env:INFISICAL_PROJECT_ID) {
        $env:INFISICAL_PROJECT_ID = (./jq -r '.workspaceId' .infisical.json)
    }
}
else {
    # If INFISICAL_PATH is empty or not set, set it to "/"
    if (-not $env:INFISICAL_PATH) {
        $env:INFISICAL_PATH = '/'
    }

    # Check if INFISICAL_PROJECT_ID is empty or not set
    if (-not $env:INFISICAL_PROJECT_ID) {
        Write-Host 'PROJECT_ID needs to be set in the workflow or in .infisical.json (with "workspaceId")'
        exit 1
    }
}

# download infisical cli

# Set the version
$env:VERSION = $env:INFISICAL_VERSION
$suffix = $env:VERSION + "_windows_amd64.zip"

# Download the Infisical CLI for Windows
Invoke-WebRequest -Uri "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$env:VERSION/infisical_$suffix" -OutFile "infisical_$suffix"

# Extract the zip file
Expand-Archive -Path "infisical_$suffix" -DestinationPath "."

# Remove the zip file
Remove-Item -Path "infisical_$suffix"

echo 'downloaded infisical cli'

# Login and get the Infisical token
$env:INFISICAL_TOKEN = ./infisical login --method=universal-auth --client-id=$env:INFISICAL_CLIENT_ID --client-secret=$env:INFISICAL_CLIENT_SECRET --silent --plain

echo 'got token'

# Export environment variables based on whether INFISICAL_ENV is set
if (-not $env:INFISICAL_ENV) {
    ./infisical export --projectId $env:INFISICAL_PROJECT_ID --path $env:INFISICAL_PATH --format json | Out-File -FilePath "env.json"
} else {
    ./infisical export --env $env:INFISICAL_ENV --projectId $env:INFISICAL_PROJECT_ID --path $env:INFISICAL_PATH --format json | Out-File -FilePath "env.json"
}

echo 'running infisical-load.py'
python3 infisical.py make_secrets

echo 'loading secrets.sh'
bash secrets.sh

echo 'loading masks.sh'
bash masks.sh

rm -f secrets.sh
rm -f masks.sh
