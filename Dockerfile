ARG DOCKER_REMOTE
ARG JF_URL
FROM ${JF_URL}/${DOCKER_REMOTE}/python:3.8-buster as builder

ARG JF_URL
ARG JF_USER
ARG JF_PASSWORD
ARG PYTHON_REMOTE_REPO
ARG DOCKER_REMOTE

# GET/CONFIGURE jfrog CLI
RUN curl -fL https://getcli.jfrog.io | sh &&  chmod 755 jfrog &&  cp jfrog /usr/local/bin/
RUN jfrog config add --artifactory-url=https://${JF_URL} --access-token=${JF_PASSWORD} --interactive=false TEMP
RUN jfrog poetry-config --repo-resolve=${PYTHON_REMOTE_REPO} --server-id=TEMP --global=true

RUN jfrog pip install poetry==1.4.2

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN touch README.md

RUN jfrog poetry install --no-root --without dev && rm -rf $POETRY_CACHE_DIR

# The runtime image, used to just run the code provided its virtual environment
FROM ${JF_URL}/${DOCKER_REMOTE}/python:3.8-slim-buster as runtime

ARG JF_URL
ARG JF_USER
ARG JF_PASSWORD
ARG PYTHON_REMOTE_REPO
ARG DOCKER_REMOTE

RUN apt-get update
RUN apt-get -y install libpq-dev gcc vim sudo

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY app ./app
WORKDIR /app

# our Chef sometimes needs to find some files on the filesystem
# we're allowing to run find with root permissions via sudo
# in this way, our Chef is able to search everywhere across the filesystem
RUN echo 'ALL ALL=(ALL) NOPASSWD: /usr/bin/find' | sudo tee /etc/sudoers.d/find_nopasswd > /dev/null

# for security, we're creating a dedicated non-root user
RUN useradd -m app
RUN chown app .
USER app