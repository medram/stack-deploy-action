#!/bin/bash

set -e
echo "Changing to deployment directory: ${{ inputs.sync_path }}"
cd ${{ inputs.sync_path }}

echo "::group::Loading environment variables"
# Load environment variables from specified files or fallback to current behavior
if [[ -n "${{ inputs.env_files }}" ]]; then
# Use specified env_files (single or multiple)

# Process the multi-line input properly by avoiding subshells
env_files_list=$(echo "${{ inputs.env_files }}" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr '\n' ' ')

for env_file in $env_files_list; do              
    # Trim whitespace
    env_file=$(echo "$env_file" | xargs)

    if [[ -f "$env_file" && -s "$env_file" ]]; then
    echo "$env_file (loaded)"
    set -a # automatically export all variables
    # Source the file but ignore errors if it fails to load
    source "$env_file" || echo "::warning::Failed to source environment file: $env_file"
    set +a
    else
    echo "::warning::Environment file not found: $env_file"
    fi
done
fi
echo "::endgroup::"

# Login to Docker registry if credentials are provided
if [[ "${{ inputs.registry_auth }}" == 'true' && -n "${{ inputs.registry_host }}" && -n "${{ inputs.registry_user }}" && -n "${{ inputs.registry_pass }}" ]]; then
echo "::group::Logging into Docker registry: ${{ inputs.registry_host }}"
echo "${{ inputs.registry_pass }}" | docker login ${{ inputs.registry_host }} -u "${{ inputs.registry_user }}" --password-stdin
echo "::endgroup::"
fi

# Deploy docker stack function
deploy_stack() {
local stack_file=$1
local stack_name=$2
shift 2

# Deploy services
echo -e "========= 📦 Deploying $stack_name services ========="
executed_command="docker stack deploy -c $stack_file ${{ inputs.registry_auth && '--with-registry-auth' }} ${{ inputs.prune && '--prune' }} --resolve-image=${{ inputs.resolve_image || 'changed' }} --detach $@ $stack_name"
echo -e "\033[0;33mCommand: $executed_command\033[0m"

docker stack deploy -c $stack_file ${{ inputs.registry_auth && '--with-registry-auth' }} ${{ inputs.prune && '--prune' }} --resolve-image=${{ inputs.resolve_image || 'changed' }} --detach $@ $stack_name
}

# Deploy stack
echo "Starting deployment of stack: ${{ inputs.stack_name }}"
if [[ -n "${{ inputs.stack_name }}" ]]
then
deploy_stack ${{ inputs.stack_file }} ${{ inputs.stack_name }} ${{ inputs.args }}
else
echo "::warning::No stack specified for deployment."
fi

# Cleanup
if [[ ${{ inputs.cleanup_sync_folder }} == "true" && "${{ inputs.sync_files }}" != "false" ]]
then
echo "::group::Cleaning up deployment directory"
rm -rf ${{ inputs.sync_path }}
echo "::endgroup::"
fi