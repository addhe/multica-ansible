# Naming Convention — multica-ansible

Semua resource yang di-provision dan dikelola oleh repo ini mengikuti konvensi penamaan berikut.

---

## GCP Resources

### Virtual Machines (VM)

| Pattern | Format |
|---------|--------|
| VM Name | `{project}-{role}-{env}-{seq}` |

**Contoh:**

| VM Name | Penjelasan |
|---------|------------|
| `multica-app-stg-001` | Multica app server, staging, instance 1 |
| `multica-db-stg-001` | Multica database, staging, instance 1 |
| `multica-app-prd-001` | Multica app server, production, instance 1 |
| `multica-orch-stg-001` | Orchestrator, staging, instance 1 |

### GCP Labels (wajib di semua VM)

| Label Key | Values | Contoh |
|-----------|--------|--------|
| `env` | `stg`, `prd` | `env=stg` |
| `role` | `app`, `db`, `orch`, `worker` | `role=app` |
| `cost_center` | nama tim/project | `cost_center=randomops` |
| `managed_by` | `ansible`, `terraform` | `managed_by=ansible` |

Label ini dipakai oleh keyed_groups di dynamic inventory:
- `tag_env_stg` — hosts dengan env=stg
- `tag_env_prd` — hosts dengan env=prd
- `tag_role_app` — hosts dengan role=app

### Machine Images (Golden Image)

| Pattern | Format |
|---------|--------|
| Image Name | `{project}-base-{env}-v{version}` |
| Image Family | `{project}-base-{env}` |

**Contoh:**

| Image Name | Family | Penjelasan |
|------------|--------|-------------|
| `multica-base-stg-v1` | `multica-base-stg` | Base image staging versi 1 |
| `multica-base-prd-v1` | `multica-base-prd` | Base image production versi 1 |
| `multica-base-stg-v2` | `multica-base-stg` | Base image staging versi 2 (auto-deprecate v1) |

### Service Accounts

| Pattern | Format |
|---------|--------|
| SA Name | `{project}-{role}-sa@{project}.iam.gserviceaccount.com` |

**Contoh:**

| SA | Penjelasan |
|----|------------|
| `multica-app-sa@ai-core-system-bot-stg.iam` | SA untuk app VM |
| `multica-packer-sa@ai-core-system-bot-stg.iam` | SA untuk Packer build |

---

## Ansible Resources

### Roles

| Pattern | Format |
|---------|--------|
| Role Name | `{service}-{component}` |

Contoh: `base-role`, `multica-db`, `multica-backend`, `multica-frontend`, `multica-cli`

### Playbooks

| Pattern | Format |
|---------|--------|
| Playbook Name | `{action}_{target}.yml` |

| Playbook | Penjelasan |
|----------|------------|
| `provision_vm.yml` | Provision GCP VM |
| `setup_base.yml` | Apply base-role ke VM |
| `deploy.yml` | Deploy full Multica stack |
| `teardown.yml` | Stop and remove services |

### Inventory

| Pattern | Format |
|---------|--------|
| Inventory Dir | `inventory/{env}/` |
| Dynamic Inventory | `inventory/{env}/gcp.yml` |
| Group Vars | `inventory/{env}/group_vars/all.yml` |
| Secrets | `inventory/{env}/secrets.yml` (vault-encrypted) |

### Variables

| Pattern | Format |
|---------|--------|
| Regular Var | `snake_case` — `postgres_db`, `backend_port` |
| Vault Secret | `vault_{name}` — `vault_postgres_password`, `vault_jwt_secret` |
| Default Value | Di `roles/{role}/defaults/main.yml` |
| Env Override | Di `inventory/{env}/group_vars/all.yml` |

---

## Packer

| Pattern | Format |
|---------|--------|
| Packer File | `packer/{image_name}.pkr.hcl` |
| Build VM (temp) | `{project}-packer-{env}` (auto-created, auto-deleted) |

---

## Environment Codes

| Environment | Code | GCP Project |
|-------------|------|-------------|
| Staging | `stg` | `ai-core-system-bot-stg` |
| Production | `prd` | `ai-core-system-bot-prd` |

---

## Versioning

- **Base Image:** Semver pattern `v{major}` — increment saat ada perubahan breaking (OS upgrade, major package change)
- **Docker Images:** Follow upstream `multica-image-tag` (default: `latest`, pin ke `v0.2.4` untuk stability)
- **Ansible Roles:** Follow `galaxy_info` version di `meta/main.yml`
