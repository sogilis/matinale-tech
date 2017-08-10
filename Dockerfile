# Base image
FROM alpine:latest
MAINTAINER Sogilis

ENV APP_NAME cyclope-api

WORKDIR /app

COPY matinale-tech /app/
COPY www /app/www/

EXPOSE 80

ENTRYPOINT /app/matinale-tech
