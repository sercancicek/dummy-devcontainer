FROM python:3.12-slim-bookworm

USER root
RUN apt-get update && apt-get install -y git curl jq sudo locales && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir cookiecutter
