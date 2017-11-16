# Base image
FROM alpine:latest
MAINTAINER Sogilis

WORKDIR /app

COPY matinale-tech /app/
COPY www /app/www/

EXPOSE 80

#ENTRYPOINT /app/matinale-tech
