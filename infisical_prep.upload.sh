set -e

# Change to the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# compile
echo "Compiling darwin arm64"
GOOS=darwin GOARCH=arm64 go build -o infisical_prep_darwin_arm64

echo "Compiling darwin amd64"
GOOS=darwin GOARCH=amd64 go build -o infisical_prep_darwin_amd64

echo "Compiling linux arm64"
GOOS=linux GOARCH=arm64 go build -o infisical_prep_linux_arm64

echo "Compiling linux amd64"
GOOS=linux GOARCH=amd64 go build -o infisical_prep_linux_amd64

echo "Compiling windows amd64"
GOOS=windows GOARCH=amd64 go build -o infisical_prep_windows_amd64.exe

echo "Compiling windows arm64"
GOOS=windows GOARCH=arm64 go build -o infisical_prep_windows_arm64.exe

# upload to R2

echo "Uploading to R2"

if [ -z "$MC_HOST_R2" ]; then
    echo "Error: MC_HOST_R2 environment variable is not set."
    exit 1
fi

mc cp infisical_prep_darwin_arm64 R2/public/bin/infisical_prep/
mc cp infisical_prep_darwin_amd64 R2/public/bin/infisical_prep/
mc cp infisical_prep_linux_arm64 R2/public/bin/infisical_prep/
mc cp infisical_prep_linux_amd64 R2/public/bin/infisical_prep/
mc cp infisical_prep_windows_amd64.exe R2/public/bin/infisical_prep/
mc cp infisical_prep_windows_arm64.exe R2/public/bin/infisical_prep/

echo "Cleaning up"
rm -f infisical_prep_darwin_arm64 infisical_prep_darwin_amd64 infisical_prep_linux_arm64 infisical_prep_linux_amd64 infisical_prep_windows_amd64.exe infisical_prep_windows_arm64.exe
