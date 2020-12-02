FROM node:14.13.1-slim as build

WORKDIR /app

COPY package.json /app

RUN yarn install && yarn cache clean

COPY . /app

RUN yarn run build

RUN yarn global add serve

FROM node:14.13.1-slim

WORKDIR /app

COPY --from=build build .

EXPOSE 5000

CMD ["serve", "-s", "build"]
