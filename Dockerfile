FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y openssh-client docker.io bash && \
    rm -rf /var/lib/apt/lists/*

# Copy scripts
COPY scripts/remote_commands.sh /scripts/remote_commands.sh
COPY scripts/summary.sh /scripts/summary.sh
COPY entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /scripts/remote_commands.sh /scripts/summary.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]