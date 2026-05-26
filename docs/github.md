# GitHub

## Create a local repository

```bash
git init
git add .
git commit -m "Initial observability stack"
git branch -M main
```

## Add a remote

SSH:

```bash
git remote add origin git@github.com:Gabba82/EstadisticasVarias.git
git push -u origin main
```

HTTPS:

```bash
git remote add origin https://github.com/Gabba82/EstadisticasVarias.git
git push -u origin main
```

## Notes

Do not commit `.env`, Grafana data or Prometheus data. They are ignored by `.gitignore`.
