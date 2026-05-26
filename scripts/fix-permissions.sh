#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p grafana/data prometheus/data
sudo chown -R 472:472 grafana
sudo chmod -R 775 grafana
sudo chown -R nobody:nogroup prometheus
sudo chmod -R 775 prometheus
echo "Permisos aplicados."
