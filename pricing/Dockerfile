#docker build -t otel-pricing:1.1 .
FROM python:3.12-slim

COPY requirements.in requirements.in

RUN --mount=type=cache,target=/root/.cache <<EOF

  pip install pip-tools && pip-compile

  pip install -r requirements.txt

EOF

COPY app.py app.py

EXPOSE 5000

ENTRYPOINT ["opentelemetry-instrument", "flask", "run", "--host=0.0.0.0"]
