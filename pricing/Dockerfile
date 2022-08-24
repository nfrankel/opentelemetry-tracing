#docker build -t otel-pricing:1.1 .
FROM python:3.12-slim

COPY requirements.in requirements.in

RUN --mount=type=cache,target=/root/.cache <<EOF

  pip install pip-tools && pip-compile
  pip install -r requirements.txt
  pip install gunicorn
  opentelemetry-bootstrap -a install

EOF

COPY app.py app.py

EXPOSE 8000

ENTRYPOINT ["opentelemetry-instrument", "gunicorn", "-b", "0.0.0.0", "-w", "4", "app:app"]
