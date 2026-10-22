# Prebuilt PHP base with the grpc and protobuf extensions compiled in.
#
# Railway builds USPP from docker/railway/Dockerfile, which compiles grpc from source when the base image lacks it:
# that step took about 45 minutes per deploy (22-23 Oct 2026, the credential rotation after Railway's incident).
# docker/railway/Dockerfile skips the PECL build when grpc and protobuf are already present, so pointing its
# BASE_IMAGE at this image makes deploys take minutes.
#
# Built and published by .github/workflows/php-grpc-base.yml to ghcr.io/interconnected-pty-ltd/php-grpc
# (public: it holds PHP and two extensions, nothing secret, and Railway pulls it without credentials).
# Rebuild it when PHP has a release: change PHP_VERSION here and in the workflow, run the workflow, then update
# BASE_IMAGE in docker/railway/Dockerfile.
ARG PHP_VERSION=8.5.12
FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf pkg-config libssl-dev zlib1g-dev g++ make \
    && MAKEFLAGS="-j$(nproc)" pecl install grpc protobuf \
    && docker-php-ext-enable grpc protobuf \
    && rm -rf /tmp/pear /var/lib/apt/lists/*

# The check docker/railway/Dockerfile relies on: both extensions load.
RUN php -m | grep -qx grpc && php -m | grep -qx protobuf
