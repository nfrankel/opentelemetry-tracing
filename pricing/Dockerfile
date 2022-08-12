#docker build -t otel-pricing:1.0 .
FROM python:3.14-slim

COPY pyproject.toml .
COPY app.py .

RUN --mount=type=cache,target=/root/.cache <<EOF

  pip install poetry==1.8.2
  poetry config virtualenvs.create false
  poetry add opentelemetry-distro[otlp]
  poetry install
  opentelemetry-bootstrap -a install

EOF

EXPOSE 8000

ENTRYPOINT ["opentelemetry-instrument", "gunicorn", "-b", "0.0.0.0", "-w", "4", "app:app"]
