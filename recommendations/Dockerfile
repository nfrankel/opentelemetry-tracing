#docker build -t otel-recommendations:1.0 .
FROM python:3.13-slim

COPY pyproject.toml .
COPY app.py .

RUN --mount=type=cache,target=/root/.cache <<EOF

  pip install poetry==1.8.4
  poetry config virtualenvs.create false
  poetry install

EOF

EXPOSE 8000

ENTRYPOINT ["fastapi", "run", "app.py"]
