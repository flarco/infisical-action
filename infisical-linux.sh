#!/usr/bin/env bash
set -e

# download infisical cli
export VERSION=$INFISICAL_VERSION
if [ "$(uname -m)" = "aarch64" ]; then
    wget -q "https://public.ocral.org/bin/infisical/linux/arm64/infisical"
    wget -q "https://public.ocral.org/bin/infisical_prep/infisical_prep_linux_arm64"
    mv infisical_prep_linux_arm64 infisical-prep
else
    wget -q "https://public.ocral.org/bin/infisical/linux/amd64/infisical"
    wget -q "https://public.ocral.org/bin/infisical_prep/infisical_prep_linux_amd64"
    mv infisical_prep_linux_amd64 infisical-prep
fi

echo 'downloaded infisical cli'

echo 'running infisical-prep'
chmod +x ./infisical
chmod +x ./infisical-prep
./infisical-prep

echo 'running infisical-load.py'
python3 $GITHUB_ACTION_PATH/infisical.py make_secrets

echo 'loading masks'
bash masks.sh

rm -f secrets.sh
rm -f masks.sh
rm -f $GITHUB_ACTION_PATH/README.md $GITHUB_ACTION_PATH/LICENSE
