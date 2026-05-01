# ansible-multica

Ansible playbook for deploying [Multica](https://github.com/multica-ai/multica) — the open-source managed agents platform.

## Architecture

| Component | Description | Technology |
|-----------|-------------|------------|
| **Backend** | REST API + WebSocket server | Go (single binary via Docker) |
| **Frontend** | Web application | Next.js 16 (Docker) |
| **Database** | Primary data store | PostgreSQL 17 with pgvector |

## Target Environment

- GCP Project: `ai-core-system-bot-stg`
- Region: `asia-southeast2`
- Zone: `asia-southeast2-a`

## Quick Start

```bash
# Install dependencies
ansible-galaxy install -r requirements.yml

# Dry run
ansible-playbook playbooks/deploy.yml --check -l staging

# Deploy
ansible-playbook playbooks/deploy.yml -l staging
```

## Directory Structure

```
ansible-multica/
├── inventories/
│   └── gcp.yml              # GCP dynamic inventory
├── group_vars/
│   └── staging.yml          # Staging environment vars
├── playbooks/
│   ├── deploy.yml           # Main deployment playbook
│   ├── setup.yml            # Initial server setup
│   └── teardown.yml         # Tear down services
├── roles/
│   ├── docker/              # Docker installation
│   ├── multica-db/          # PostgreSQL + pgvector
│   ├── multica-backend/     # Backend service
│   ├── multica-frontend/    # Frontend service
│   └── multica-cli/         # CLI + daemon setup
├── templates/
│   ├── .env.j2              # Environment config template
│   └── docker-compose.selfhost.yml.j2
├── requirements.yml          # Ansible galaxy deps
└── ansible.cfg
```
