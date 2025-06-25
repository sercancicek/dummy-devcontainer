FROM python:3.12-slim-bookworm

USER root
RUN apt-get update && apt-get install -y git curl jq sudo locales && \
    rm -rf /var/lib/apt/lists/*

# Create picnic user
RUN groupadd --gid 1000 picnic \
    && useradd --create-home --uid 1000 --gid 1000 picnic \
    && echo picnic ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/picnic \
    && chmod 0440 /etc/sudoers.d/picnic

USER picnic

# Install cookiecutter
RUN pip install --no-cache-dir cookiecutter
USER root
