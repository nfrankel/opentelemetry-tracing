#docker build -t otel-analytics:1.0 .
FROM node:22-alpine AS build

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile --non-interactive

COPY src/index.ts src/index.ts
COPY tsconfig.json .

RUN yarn run build

FROM node:22-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY --from=build /usr/src/app/node_modules node_modules/
COPY --from=build /usr/src/app/dist/index.js dist/

CMD ["yarn", "run", "start"]
