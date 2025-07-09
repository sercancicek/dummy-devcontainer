FROM python:3.12-slim-bookworm

ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ARG PROJECT_NAME

USER root
RUN apt-get update && apt-get install -y git curl jq sudo locales && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --extra-index-url https://${NEXUS_USERNAME}:${NEXUS_PASSWORD}@nexus.global.picnicinternational.com/repository/pypi-public/simple/ cookiecutter
