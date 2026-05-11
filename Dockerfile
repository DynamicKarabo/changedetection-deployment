# =============================================================================
# Changedetection.io — Multi-stage Docker Build
# Target: Python slim image (~350MB)
# =============================================================================

# Stage 1: Build dependencies
FROM python:3.12-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    libxslt-dev \
    libjpeg-dev \
    zlib1g-dev \
    pkg-config \
    make \
    patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY src/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxslt1.1 \
    locales \
    poppler-utils \
    file \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

LABEL org.opencontainers.image.title="Changedetection.io — website change detection"
LABEL org.opencontainers.image.description="Monitor website changes with notifications and visual diffs"
LABEL org.opencontainers.image.source="https://github.com/DynamicKarabo/changedetection-deployment"
LABEL org.opencontainers.image.authors="Karabo Oliphant"

WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY src/ .

ENV PATH=/root/.local/bin:$PATH
ENV PORT=5000
ENV LISTEN_HOST=0.0.0.0

EXPOSE ${PORT}

VOLUME ["/datastore"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl --fail http://localhost:${PORT:-5000}/worker-health || exit 1

ENTRYPOINT ["python"]
CMD ["changedetection.py", "-d", "/datastore"]
