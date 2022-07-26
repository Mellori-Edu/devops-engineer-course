FROM node:14-alpine as build

RUN mkdir -p /app/src
WORKDIR /app/src

COPY ./src/package.json .
# COPY ./src/package-lock.json .
RUN npm install