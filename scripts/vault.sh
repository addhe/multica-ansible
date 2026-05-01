#!/usr/bin/env bash
set -euo pipefail
VAULT_DIR="$(dirname "$0")/.."
case "${1:-help}" in
  encrypt-staging)
    ansible-vault encrypt "$VAULT_DIR/inventory/staging/secrets.yml"
    ;;
  decrypt-staging)
    ansible-vault decrypt "$VAULT_DIR/inventory/staging/secrets.yml"
    ;;
  encrypt-production)
    ansible-vault encrypt "$VAULT_DIR/inventory/production/secrets.yml"
    ;;
  decrypt-production)
    ansible-vault decrypt "$VAULT_DIR/inventory/production/secrets.yml"
    ;;
  edit-staging)
    ansible-vault edit "$VAULT_DIR/inventory/staging/secrets.yml"
    ;;
  edit-production)
    ansible-vault edit "$VAULT_DIR/inventory/production/secrets.yml"
    ;;
  help|*)
    echo "Usage: $0 {encrypt-staging|decrypt-staging|encrypt-production|decrypt-production|edit-staging|edit-production}"
    ;;
esac
