# EstadisticasVarias

Docker stack for monitoring home services and devices with Grafana, Prometheus, cAdvisor and Node Exporter.

The first included module monitors an Emby server and the host that runs it. It is designed for a Linux or CasaOS server where Emby runs in Docker. The default dashboard looks for containers whose name matches `.*emby.*`, but that can be changed from Grafana.

## What It Includes

- Grafana on port `3030` by default.
- Prometheus on port `9090`, bound to localhost by default.
- cAdvisor on port `8085`, bound to localhost by default.
- Node Exporter on port `9100`, bound to localhost by default.
- Provisioned Prometheus datasource in Grafana.
- Provisioned Emby traffic dashboard.
- `.env` based configuration for ports, credentials, image tags and retention.

## Structure

```text
EstadisticasVarias/
|-- docker-compose.yml
|-- .env.example
|-- prometheus/
|   |-- prometheus.yml
|   `-- data/
|-- grafana/
|   |-- dashboards/
|   |   `-- emby-traffic-monitor.json
|   |-- provisioning/
|   |   |-- dashboards/dashboards.yml
|   |   `-- datasources/prometheus.yml
|   `-- data/
|-- docs/
|   |-- configuration.md
|   |-- github.md
|   `-- homeassistant-roadmap.md
`-- scripts/
    `-- fix-permissions.sh
```

## Installation

Clone or copy the project to your server:

```bash
cd /DATA/AppData
mkdir -p observatorio
cd observatorio
```

Create your environment file:

```bash
cp .env.example .env
```

Edit `.env` and at least change:

```text
GRAFANA_ADMIN_PASSWORD=CambiaEstaPassword
```

Prepare permissions and start the stack:

```bash
chmod +x scripts/fix-permissions.sh
./scripts/fix-permissions.sh
docker compose up -d
```

Open Grafana:

```text
http://SERVER-IP:3030
```

Default credentials come from `.env`.

## Configuration

Main settings live in `.env`. See [docs/configuration.md](docs/configuration.md).

The safest default is to expose only Grafana to the LAN. Prometheus, cAdvisor and Node Exporter are bound to `127.0.0.1` unless you change their bind address.

## Dashboard

The included dashboard shows:

- GB sent by Emby in the selected time range.
- GB received by Emby in the selected time range.
- Current Emby RAM usage.
- Current Emby CPU usage in cores.
- Clean network input/output rates.

The dashboard has a Grafana variable called `container_regex`.

Default:

```text
.*emby.*
```

If your container has another name, change that variable from the dashboard.

## Main Queries

GB sent by Emby in the selected range:

```promql
sum(increase(container_network_transmit_bytes_total{name=~"$container_regex"}[$__range])) / 1024 / 1024 / 1024
```

GB received by Emby in the selected range:

```promql
sum(increase(container_network_receive_bytes_total{name=~"$container_regex"}[$__range])) / 1024 / 1024 / 1024
```

Outgoing speed:

```promql
sum(rate(container_network_transmit_bytes_total{name=~"$container_regex"}[5m]))
```

Incoming speed:

```promql
sum(rate(container_network_receive_bytes_total{name=~"$container_regex"}[5m]))
```

RAM:

```promql
sum(container_memory_usage_bytes{name=~"$container_regex"})
```

CPU cores:

```promql
sum(rate(container_cpu_usage_seconds_total{name=~"$container_regex"}[5m]))
```

## Troubleshooting

### Grafana permission denied

Symptom:

```text
GF_PATHS_DATA='/var/lib/grafana' is not writable
mkdir: can't create directory '/var/lib/grafana/plugins': Permission denied
```

Fix:

```bash
cd /DATA/AppData/observatorio
sudo chown -R 472:472 grafana
sudo chmod -R 775 grafana
docker compose restart grafana
```

### Prometheus queries.active permission denied

Symptom:

```text
open /prometheus/queries.active: permission denied
panic: Unable to create mmap-ed active query log
```

Fix:

```bash
cd /DATA/AppData/observatorio
sudo chown -R nobody:nogroup prometheus
sudo chmod -R 775 prometheus
docker compose restart prometheus
```

### Port already in use

Change the relevant port in `.env`, then restart:

```bash
docker compose up -d
```

To inspect used ports on Linux:

```bash
sudo ss -tulpn | grep -E ':3000|:3001|:3030|:9090|:8085|:9100'
```

## GitHub

See [docs/github.md](docs/github.md).

## Future Modules

This project is intended to grow into a broader home observability stack. The next likely module is Home Assistant energy and device usage monitoring. See [docs/homeassistant-roadmap.md](docs/homeassistant-roadmap.md).

## Limits

This stack currently measures container and host metrics:

- Network traffic.
- CPU.
- RAM.
- Basic health.

It does not yet identify:

- Emby user.
- Movie or episode title.
- Historical playback by Emby user.
- Home Assistant device usage.

Those can be added later with Emby API, Emby logs and Home Assistant Prometheus metrics.
