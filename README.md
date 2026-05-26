# EstadisticasVarias

Stack Docker para monitorizar servicios, contenedores y dispositivos del hogar con Grafana, Prometheus, cAdvisor y Node Exporter.

El primer módulo incluido monitoriza un servidor Emby y el host donde se ejecuta. Está pensado para un servidor Linux o CasaOS con Emby funcionando en Docker. El dashboard busca por defecto contenedores cuyo nombre coincida con `.*emby.*`, pero se puede cambiar desde Grafana.

## Qué Incluye

- Grafana en el puerto `3030` por defecto.
- Prometheus en el puerto `9090`, ligado a `127.0.0.1` por defecto.
- cAdvisor en el puerto `8085`, ligado a `127.0.0.1` por defecto.
- Node Exporter en el puerto `9100`, ligado a `127.0.0.1` por defecto.
- Datasource de Prometheus autoconfigurado en Grafana.
- Dashboard de tráfico de Emby autoprovisionado.
- Configuración mediante `.env` para puertos, credenciales, versiones de imágenes y retención de métricas.

## Estructura

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

## Instalación

Clona o copia el proyecto en tu servidor:

```bash
cd /DATA/AppData
mkdir -p observatorio
cd observatorio
```

Crea tu archivo de entorno:

```bash
cp .env.example .env
```

Edita `.env` y cambia al menos la contraseña inicial de Grafana:

```text
GRAFANA_ADMIN_PASSWORD=CambiaEstaPassword
```

Prepara permisos y arranca el stack:

```bash
chmod +x scripts/fix-permissions.sh
./scripts/fix-permissions.sh
docker compose up -d
```

Abre Grafana en:

```text
http://IP-DEL-SERVIDOR:3030
```

Las credenciales iniciales salen de `.env`.

## Configuración

La configuración principal vive en `.env`. Puedes ver más detalle en [docs/configuration.md](docs/configuration.md).

Por seguridad, el valor por defecto expone solo Grafana a la red. Prometheus, cAdvisor y Node Exporter quedan ligados a `127.0.0.1` salvo que cambies sus variables de bind address.

## Dashboard

El dashboard incluido muestra:

- GB enviados por Emby en el rango de tiempo seleccionado.
- GB recibidos por Emby en el rango de tiempo seleccionado.
- Uso actual de RAM de Emby.
- Uso actual de CPU de Emby en cores.
- Velocidad limpia de entrada y salida de red.

El dashboard tiene una variable de Grafana llamada `container_regex`.

Valor por defecto:

```text
.*emby.*
```

Si tu contenedor tiene otro nombre, cambia esa variable desde el dashboard sin editar todas las consultas PromQL.

## Consultas Principales

GB enviados por Emby en el rango seleccionado:

```promql
sum(increase(container_network_transmit_bytes_total{name=~"$container_regex"}[$__range])) / 1024 / 1024 / 1024
```

GB recibidos por Emby en el rango seleccionado:

```promql
sum(increase(container_network_receive_bytes_total{name=~"$container_regex"}[$__range])) / 1024 / 1024 / 1024
```

Velocidad de salida:

```promql
sum(rate(container_network_transmit_bytes_total{name=~"$container_regex"}[5m]))
```

Velocidad de entrada:

```promql
sum(rate(container_network_receive_bytes_total{name=~"$container_regex"}[5m]))
```

RAM:

```promql
sum(container_memory_usage_bytes{name=~"$container_regex"})
```

CPU en cores:

```promql
sum(rate(container_cpu_usage_seconds_total{name=~"$container_regex"}[5m]))
```

## Solución de Problemas

### Grafana muestra permission denied

Síntoma:

```text
GF_PATHS_DATA='/var/lib/grafana' is not writable
mkdir: can't create directory '/var/lib/grafana/plugins': Permission denied
```

Solución:

```bash
cd /DATA/AppData/observatorio
sudo chown -R 472:472 grafana
sudo chmod -R 775 grafana
docker compose restart grafana
```

### Prometheus muestra queries.active permission denied

Síntoma:

```text
open /prometheus/queries.active: permission denied
panic: Unable to create mmap-ed active query log
```

Solución:

```bash
cd /DATA/AppData/observatorio
sudo chown -R nobody:nogroup prometheus
sudo chmod -R 775 prometheus
docker compose restart prometheus
```

### Un puerto ya está ocupado

Cambia el puerto correspondiente en `.env` y reinicia:

```bash
docker compose up -d
```

Para revisar puertos usados en Linux:

```bash
sudo ss -tulpn | grep -E ':3000|:3001|:3030|:9090|:8085|:9100'
```

## GitHub

Consulta [docs/github.md](docs/github.md).

## Próximos Módulos

Este proyecto está pensado para crecer como stack de observabilidad doméstica. El siguiente módulo natural es la monitorización de consumos y usos desde Home Assistant. Consulta [docs/homeassistant-roadmap.md](docs/homeassistant-roadmap.md).

## Límites Actuales

Este stack mide métricas del contenedor y del host:

- Tráfico de red.
- CPU.
- RAM.
- Estado básico.

Todavía no identifica:

- Usuario de Emby.
- Película o episodio reproducido.
- Histórico de reproducciones por usuario de Emby.
- Uso de dispositivos de Home Assistant.

Estas funciones se podrán añadir más adelante con la API de Emby, logs de Emby y métricas Prometheus de Home Assistant.
