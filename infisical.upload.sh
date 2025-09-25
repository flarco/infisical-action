set -e 

RELEASE='0.28.1'

# https://github.com/Infisical/infisical/releases
echo "Downloading infisical cli for all platforms"

wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_darwin_arm64.tar.gz" -O infisical_darwin_arm64.tar.gz
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_darwin_amd64.tar.gz" -O infisical_darwin_amd64.tar.gz
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_linux_arm64.tar.gz" -O infisical_linux_arm64.tar.gz
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_linux_amd64.tar.gz" -O infisical_linux_amd64.tar.gz
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_windows_amd64.zip" -O infisical_windows_amd64.zip
wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$RELEASE/infisical_${RELEASE}_windows_arm64.zip" -O infisical_windows_arm64.zip

echo "Uploading to R2"

if [ -z "$MC_HOST_R2" ]; then
    echo "Error: MC_HOST_R2 environment variable is not set."
    exit 1
fi

# unarchive into respective folders
for platform in darwin_arm64 darwin_amd64 linux_arm64 linux_amd64; do
    os=${platform%_*}
    arch=${platform#*_}
    mkdir -p "infisical/$os/$arch"
    tar -xzf "infisical_${platform}.tar.gz" -C "infisical/$os/$arch"
    mc cp "infisical/$os/$arch/infisical" R2/public/bin/infisical/$os/$arch/infisical
    rm -rf "infisical/$os/$arch"
    rm -f "infisical_${platform}.tar.gz"
done


for arch in amd64 arm64; do
  # unzip windows
  mkdir -p "infisical/windows/$arch"
  unzip infisical_windows_$arch.zip -d "infisical/windows/$arch"
  mc cp "infisical/windows/$arch/infisical.exe" R2/public/bin/infisical/windows/$arch/infisical.exe
  rm -rf "infisical/windows/$arch"
  rm -f infisical_windows_$arch.zip
done