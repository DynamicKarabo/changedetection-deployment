# Changedetection.io — Production Deployment Pipeline

> Multi-stage Docker build, CI/CD with security scanning, healthcheck, and automated deployment.

## Before & After

| Metric | Before (Official Dockerfile) | After (This Pipeline) |
|--------|-----------------------------|-----------------------|
| Build stages | 1 (all-in-one) | 2 (pip build → slim runtime) |
| Security scanning | None | Trivy (CRITICAL/HIGH blocks build) |
| SBOM generation | None | SPDX JSON per build |
| Caching | None | GitHub Actions cache (faster rebuilds) |
| Healthcheck | None | Built-in curl check |

## Pipeline

```
[Push/PR] → Docker build → Smoke test → Trivy scan → SBOM → GHCR push → Done
```

## Quick Start

```bash
docker compose up -d
```

Or pull from GHCR:

```bash
docker pull ghcr.io/dynamickarabo/changedetection-deployment:latest
docker run -d -p 5000:5000 \
  -v changedetection-data:/datastore \
  ghcr.io/dynamickarabo/changedetection-deployment:latest
```

## Configuration

| Env Var | Default | Description |
|---------|---------|-------------|
| PORT | 5000 | Listen port |
| LISTEN_HOST | 0.0.0.0 | Listen address |
| BASE_URL | — | Base URL for external links |
| PLAYWRIGHT_DRIVER_URL | ws://playwright-chrome:3000 | External Playwright endpoint |

**Playwright/JavaScript rendering:** The image doesn't bundle Playwright by default. Use an external Playwright container:

```yaml
services:
  changedetection:
    environment:
      PLAYWRIGHT_DRIVER_URL: ws://playwright-chrome:3000
  playwright-chrome:
    image: browserless/chrome:latest
    restart: unless-stopped
```

## Tech Stack

- **Runtime:** Python 3.12-slim-bookworm
- **Framework:** Flask
- **Database:** File-based JSON datastore
- **CI/CD:** GitHub Actions
- **Security:** Trivy, SBOM (SPDX)
- **Registry:** GitHub Container Registry (GHCR)
