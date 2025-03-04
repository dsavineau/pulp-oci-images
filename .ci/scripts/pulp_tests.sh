#!/usr/bin/env bash
# coding=utf-8
set -euo pipefail

SERVER="pulp.example.com"
WEB_PORT=8080

echo 127.0.0.1   pulp.example.com pulp_api pulp_content | sudo tee -a /etc/hosts

# From the pulp-server/pulp-api config-map
echo "machine $SERVER
login admin
password password

machine pulp_api
login admin
password password

machine pulp_content
login admin
password password
" > ~/.netrc
chmod og-rw ~/.netrc

export BASE_ADDR="http://$SERVER:$WEB_PORT"
echo $BASE_ADDR

if [ -z "$(pip3 freeze | grep pulp-cli)" ]; then
  echo "Installing pulp-cli"
  pip3 install --user pulp-cli[pygments]
fi

if [ ! -f ~/.config/pulp/settings.toml ]; then
  echo "Configuring pulp-cli"
  mkdir -p ~/.config/pulp
  cat > ~/.config/pulp/cli.toml << EOF
[cli]
base_url = "$BASE_ADDR"
verify_ssl = false
format = "json"
EOF
fi

cat ~/.config/pulp/cli.toml | tee ~/.config/pulp/settings.toml

pulp status | jq
