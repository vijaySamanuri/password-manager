FROM node:14.13.1-slim as build

WORKDIR /app

COPY package.json /app

RUN yarn install && yarn cache clean

COPY . /app

RUN yarn run build


FROM node:14.13.1-slim

WORKDIR /app

COPY --from=build /app/build build/

RUN yarn global add serve

EXPOSE 5000

CMD ["serve", "-s", "build"]
