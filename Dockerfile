# ----------- Tahap 1: builder -----------
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ----------- Tahap 2: runtime -----------
FROM python:3.11-slim

LABEL org.opencontainers.image.title="sentra"
LABEL org.opencontainers.image.vendor="Politeknik Negeri Batam"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=src/app.py \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5000

# Buat pengguna non-root
RUN groupadd --system sentra \
 && useradd --system --gid sentra --home /app sentra

WORKDIR /app

# Salin HANYA hasil pemasangan dari tahap builder
COPY --from=builder /install /usr/local
COPY --chown=sentra:sentra src/ ./src/

USER sentra

EXPOSE 5000

HEALTHCHECK --interval=5s --timeout=3s --start-period=3s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2)" || exit 1

CMD ["python3", "src/app.py"]
