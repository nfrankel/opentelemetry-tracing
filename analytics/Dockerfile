#docker build -t otel-analytics:1.0 .
FROM node:21-alpine AS build

WORKDIR /usr/src/app

COPY package.json .

RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile --non-interactive --production=true

COPY src/index.ts src/index.ts
COPY tsconfig.json .

RUN yarn run build

FROM node:21-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY --from=build /usr/src/app/node_modules node_modules/
COPY --from=build /usr/src/app/dist/index.js dist/

CMD ["yarn", "run", "start"]
