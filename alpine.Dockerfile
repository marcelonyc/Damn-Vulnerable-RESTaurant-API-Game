ARG DOCKER_REMOTE
ARG JF_URL
FROM ${JF_URL}/${DOCKER_REMOTE}/python:3.10-alpine3.20 as builder

ARG JF_URL
ARG JF_USER
ARG JF_PASSWORD
ARG PYTHON_REMOTE_REPO
ARG DOCKER_REMOTE

# GET/CONFIGURE jfrog CLI
RUN curl -fL https://install-cli.jfrog.io | sh
RUN jf config add --artifactory-url=https://${JF_URL}/artifactory --access-token=${JF_PASSWORD} --interactive=false TEMP
RUN jf pipc --repo-resolve=${PYTHON_REMOTE_REPO} --server-id-resolve=TEMP --global=True

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN touch README.md

RUN jf pip install -r requirements.txt 

# The runtime image, used to just run the code provided its virtual environment
FROM ${JF_URL}/${DOCKER_REMOTE}/python:3.10-alpine3.20 as runtime

ARG JF_URL
ARG JF_USER
ARG JF_PASSWORD
ARG PYTHON_REMOTE_REPO


RUN apk update && apk add libpq gcc vim sudo

COPY app ./app
WORKDIR /app

# our Chef sometimes needs to find some files on the filesystem
# we're allowing to run find with root permissions via sudo
# in this way, our Chef is able to search everywhere across the filesystem
RUN echo 'ALL ALL=(ALL) NOPASSWD: /usr/bin/find' | sudo tee /etc/sudoers.d/find_nopasswd > /dev/null

# for security, we're creating a dedicated non-root user
RUN adduser app
RUN chown app .
USER app
