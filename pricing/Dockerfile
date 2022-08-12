#docker build -t otel-pricing:1.0 .
FROM python:3.11

COPY requirements.in requirements.in

RUN pip install pip-tools && pip-compile
RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt

RUN pip install opentelemetry-distro[otlp]==0.40b0 \
 && pip install opentelemetry-instrumentation==0.40b0 \
 && pip install opentelemetry-instrumentation-flask==0.40b0

COPY app.py app.py

EXPOSE 5000
ENTRYPOINT ["opentelemetry-instrument", "flask", "run", "--host=0.0.0.0"]
