# Base image
FROM debian:latest
MAINTAINER Sogilis

WORKDIR /app

COPY matinale-tech /app/
COPY www /app/www/

EXPOSE 80

ENTRYPOINT /app/matinale-tech
