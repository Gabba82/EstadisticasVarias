# Configuration

This stack is configured mostly through `.env`.

Start from the example:

```bash
cp .env.example .env
```

Edit `.env` before the first `docker compose up -d`.

## Important variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `GRAFANA_PORT` | `3030` | Public Grafana port. |
| `GRAFANA_BIND_ADDRESS` | `0.0.0.0` | Address where Grafana listens. |
| `GRAFANA_ADMIN_USER` | `admin` | Initial Grafana user. |
| `GRAFANA_ADMIN_PASSWORD` | `CambiaEstaPassword` | Initial Grafana password. Change it. |
| `PROMETHEUS_PORT` | `9090` | Prometheus port. Bound to localhost by default. |
| `CADVISOR_PORT` | `8085` | cAdvisor port. Bound to localhost by default. |
| `NODE_EXPORTER_PORT` | `9100` | Node Exporter port. Bound to localhost by default. |
| `PROMETHEUS_RETENTION` | `30d` | How long Prometheus keeps local metrics. |

## Exposing services

Grafana is the only service that usually needs to be reachable from another browser.

Prometheus, cAdvisor and Node Exporter expose operational data about the host. Keep them on `127.0.0.1` unless you have a reverse proxy, firewall or VPN in front.

## Emby container selector

The Grafana dashboard includes a `container_regex` variable. Its default value is:

```text
.*emby.*
```

If your Emby container has another name, change the variable in the dashboard instead of editing every query.

Examples:

```text
emby
embyserver
.*media.*
```
