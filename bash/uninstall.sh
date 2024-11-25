#!/bin/bash

# This script uninstalls Terraform, Ansible, AWS CLI, Azure CLI, and other tools

# if [ "$EUID" -ne 0 ]; then
#   echo "Please run as root"
#   exit 1
# fi

# import functions
source bash/functions.sh
setup_logging "uninstall"

# List of Bitnami releases to uninstall
releases=("airflow" "minio" "postgresql" "spark" "jupyter" "mlflow" "prometheus" "grafana" "jenkins")

# Uninstall each release
for release in "${releases[@]}"; do
    if ! helm list -A | grep -q $release; then
        echo "$release is not installed"
        continue
    fi
    echo "Uninstalling $release..."
    helm uninstall $release -n default
done

echo "All specified Bitnami services have been uninstalled."

# additional cleanup
echo "Deleting persistent volumes..."
kubectl delete pvc --all

check_status
