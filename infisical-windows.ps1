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

export INFISICAL_TOKEN=$(./infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --silent --plain)

echo 'got token'
if [ -z "$INFISICAL_ENV" ]; then
  ./infisical export --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
else
  ./infisical export --env "$INFISICAL_ENV" --projectId "$INFISICAL_PROJECT_ID" --path "$INFISICAL_PATH" --format json > env.json
fi

echo 'running infisical-load.py'
python3 infisical.py make_secrets

echo 'loading secrets.sh'
bash secrets.sh

echo 'loading masks.sh'
bash masks.sh

rm -f secrets.sh
rm -f masks.sh
