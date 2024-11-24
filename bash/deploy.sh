#!/bin/bash

# This script deploys containerized applications to Kubernetes cluster
# using kubectl, helm, terraform, jenkins, and other tools

# if [ "$EUID" -ne 0 ]; then
#   echo "Please run as root"
#   exit 1
# fi

# import functions.sh
source bash/functions.sh
setup_logging "deploy"


