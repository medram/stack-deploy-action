#!/bin/bash

set -e

printenv

# echo "Changing to deployment directory: $INPUT_SYNC_PATH"
# cd $INPUT_SYNC_PATH
# echo pwd

echo "Changing to deployment directory: /home/mrmed/.deploy/my-cloud-architecture"
ls -lahp /home/mrmed/.deploy/my-cloud-architecture
echo pwd
cd /home/mrmed/.deploy/my-cloud-architecture

echo "::group::Loading environment variables"
# Load environment variables from specified files or fallback to current behavior
if [[ -n "$INPUT_ENV_FILES" ]]; then
    echo "in .... ;D"
    # Use specified env_files (single or multiple)
    # Process the multi-line input properly by avoiding subshells
    env_files_list=$(echo "$INPUT_ENV_FILES" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr '\n' ' ')
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
if [[ "$INPUT_REGISTRY_AUTH" == 'true' && -n "$INPUT_REGISTRY_HOST" && -n "$INPUT_REGISTRY_USER" && -n "$INPUT_REGISTRY_PASS" ]]; then
echo "::group::Logging into Docker registry: $INPUT_REGISTRY_HOST"
echo "$INPUT_REGISTRY_PASS" | docker login $INPUT_REGISTRY_HOST -u "$INPUT_REGISTRY_USER" --password-stdin
echo "::endgroup::"
fi

# Deploy docker stack function
deploy_stack() {
    local stack_file=$1
    local stack_name=$2
    shift 2

    # Deploy services
    echo -e "========= 📦 Deploying $stack_name services ========="
    registry_auth_flag=""
    prune_flag=""
    if [[ "$INPUT_REGISTRY_AUTH" == 'true' ]]; then
        registry_auth_flag="--with-registry-auth"
    fi
    if [[ "$INPUT_PRUNE" == 'true' ]]; then
        prune_flag="--prune"
    fi
    resolve_image_option="${INPUT_RESOLVE_IMAGE:-changed}"

    executed_command="docker stack deploy -c $stack_file $registry_auth_flag $prune_flag --resolve-image=$resolve_image_option --detach $@ $stack_name"
    echo -e "\033[0;33mCommand: $executed_command\033[0m"

    docker stack deploy -c $stack_file $registry_auth_flag $prune_flag --resolve-image=$resolve_image_option --detach $@ $stack_name
}

# Deploy stack
echo "Starting deployment of stack: $INPUT_STACK_NAME"
if [[ -n "$INPUT_STACK_NAME" ]]; then
    deploy_stack $INPUT_STACK_FILE $INPUT_STACK_NAME $INPUT_ARGS
else
    echo "::warning::No stack specified for deployment."
fi

# Cleanup
if [[ "$INPUT_CLEANUP_SYNC_FOLDER" == "true" && "$INPUT_SYNC_FILES" != "false" ]]
then
    echo "::group::Cleaning up deployment directory"
    rm -rf $INPUT_SYNC_PATH
    echo "::endgroup::"
fi