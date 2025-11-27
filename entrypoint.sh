#!/bin/bash
set -e

# Export all inputs as environment variables
export HOST="${HOST}"
export SSH_KEY="${SSH_KEY}"
export USER="${USER:-root}"
export PORT="${PORT:-22}"
export PASS="${PASS:-}"
export STACK_NAME="${STACK_NAME}"
export STACK_FILE="${STACK_FILE:-docker-compose.yml}"
export PRUNE="${PRUNE:-true}"
export RESOLVE_IMAGE="${RESOLVE_IMAGE:-changed}"
export ENV_FILES="${ENV_FILES:-}"
export ARGS="${ARGS:-}"
export SYNC_PATH="${SYNC_PATH:-/tmp/stack-deploy-action}"
export REGISTRY_AUTH="${REGISTRY_AUTH:-true}"
export REGISTRY_HOST="${REGISTRY_HOST:-docker.io}"
export REGISTRY_USER="${REGISTRY_USER:-}"
export REGISTRY_PASS="${REGISTRY_PASS:-}"
export SUMMARY="${SUMMARY:-true}"
export CLEANUP_SYNC_FOLDER="${CLEANUP_SYNC_FOLDER:-true}"
export SYNC_FILES="${SYNC_FILES:-true}"

# Run deployment script
/scripts/remote_commands.sh

# Optionally run summary script
if [ "$SUMMARY" == "true" ]; then
  /scripts/summary.sh
fi