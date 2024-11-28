ARG IMAGE_PREFIX=
ARG REDMINE_IMAGE=redmine:5.1.4
FROM ${IMAGE_PREFIX}${REDMINE_IMAGE} as base

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        build-essential \
        ruby-dev \
        libgmp-dev \
        libssl-dev \
	; \
	rm -rf /var/lib/apt/lists/*