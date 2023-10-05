#docker build -t otel-analytics:1.0 .
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile --non-interactive --production=true

COPY index.js .

CMD ["node", "index.js"]
