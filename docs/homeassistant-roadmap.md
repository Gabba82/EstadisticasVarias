# Home Assistant Roadmap

The current stack observes the Docker host and the Emby container.

Home Assistant can be added later as a metrics source through Prometheus:

```text
devices and sensors -> Home Assistant -> Prometheus -> Grafana
```

Planned dashboards:

- Instant power by device in W.
- Daily, weekly and monthly energy in kWh.
- Estimated cost by device or room.
- Switch usage and on/off history.
- Temperature, humidity and presence summaries.

Planned configuration:

- Add the Home Assistant Prometheus integration.
- Add a Prometheus scrape job for `/api/prometheus`.
- Store the Home Assistant token outside git.
- Add Grafana dashboards for energy and device usage.
