# Stack Deploy Action

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/medram/stack-deploy-action/CI)
![License](https://img.shields.io/github/license/medram/stack-deploy-action)
![Version](https://img.shields.io/github/v/tag/medram/stack-deploy-action)

## Overview

Deploy Docker Swarm stacks to a remote server via SSH, with file sync, registry authentication, environment loading, and automated cleanup. This action is ideal for CI/CD workflows targeting Docker Swarm clusters.

## Features

- Syncs files to remote server before deployment
- Deploys Docker Swarm stack using `docker stack deploy`
- Supports registry authentication
- Loads environment files
- Cleans up synced files after deployment
- Adds deployment summary to GitHub Actions step summary

## Usage

### Basic Example

```yaml
name: Deploy Stack
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy Docker Swarm Stack
        uses: medram/stack-deploy-action@v1
        with:
          host: ${{ secrets.SWARM_HOST }}
          ssh_key: ${{ secrets.SSH_KEY }}
          user: root
          stack_name: my-stack
          stack_file: docker-compose.yml
          registry_auth: true
          registry_user: ${{ secrets.REGISTRY_USER }}
          registry_pass: ${{ secrets.REGISTRY_PASS }}
```

### Advanced Example: Multi-Stack Deployment

```yaml
name: Multi-Stack Deploy
on: workflow_dispatch
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy API Stack
        uses: medram/stack-deploy-action@v1
        with:
          host: ${{ secrets.SWARM_HOST }}
          ssh_key: ${{ secrets.SSH_KEY }}
          stack_name: api-stack
          stack_file: api-compose.yml
          env_files: |
            .env.api
            .env.shared
      - name: Deploy Web Stack
        uses: medram/stack-deploy-action@v1
        with:
          host: ${{ secrets.SWARM_HOST }}
          ssh_key: ${{ secrets.SSH_KEY }}
          stack_name: web-stack
          stack_file: web-compose.yml
          env_files: |
            - .env.web
            - .env.shared
```

### Advanced Example: Custom Environment Files

```yaml
- name: Deploy with Custom Env Files
  uses: medram/stack-deploy-action@v1
  with:
    host: ${{ secrets.SWARM_HOST }}
    ssh_key: ${{ secrets.SSH_KEY }}
    stack_name: custom-stack
    stack_file: custom-compose.yml
    env_files: |
      - .env.production
      - .env.database
```

## Inputs

| Name                | Description                                      | Required | Default                      |
| ------------------- | ------------------------------------------------ | -------- | ---------------------------- |
| host                | SSH host/IP of Swarm manager                     | Yes      |                              |
| ssh_key             | SSH private key                                  | No       |                              |
| user                | SSH username                                     | No       | root                         |
| port                | SSH port                                         | No       | 22                           |
| pass                | SSH password                                     | No       |                              |
| stack_name          | Docker Swarm stack name                          | Yes      |                              |
| stack_file          | Path to Docker Compose file                      | No       | docker-compose.yml           |
| prune               | Prune services not in stack file                 | No       | true                         |
| resolve_image       | Image resolution strategy                        | No       | changed                      |
| env_files           | Additional environment files (newline separated) | No       |                              |
| args                | Extra arguments for deploy command               | No       |                              |
| sync_path           | Remote sync path                                 | No       | /tmp/stack-deploy-action/... |
| registry_auth       | Use registry authentication                      | No       | true                         |
| registry_host       | Docker registry host                             | No       | docker.io                    |
| registry_user       | Docker registry username                         | No       |                              |
| registry_pass       | Docker registry password                         | No       |                              |
| summary             | Add deployment summary                           | No       | true                         |
| cleanup_sync_folder | Clean up synced files after deployment           | No       | true                         |
| sync_files          | Sync files before deployment                     | No       | true                         |

## Outputs

- **Deployment Summary**: Adds a summary to the workflow run with stack name, file, and deployment time.

## Security & Best Practices

- Use GitHub Secrets for sensitive values (host, SSH key, registry credentials).
- Limit SSH access to trusted users.
- Review Docker Compose files for security.

## Troubleshooting

- Ensure SSH credentials are correct.
- Check remote server Docker Swarm setup.
- Review workflow logs for errors.

## License

See [`LICENSE`](LICENSE:1).

## Author

Mohammed Ramouchy
