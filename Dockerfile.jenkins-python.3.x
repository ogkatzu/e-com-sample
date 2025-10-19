FROM jenkins/inbound-agent:latest

USER root

RUN apt-get update && \
    apt-get install -y wget unzip curl python3 python3-pip python3-venv && \
    pip3 install --no-cache-dir --break-system-packages pipenv && \
    rm -rf /var/lib/apt/lists/*

RUN python3 --version && pip3 --version && pipenv --version

# Switch back to jenkins user
USER jenkins

# Set working directory
WORKDIR /home/jenkins
