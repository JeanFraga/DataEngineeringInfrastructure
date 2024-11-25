#!/bin/bash

# This script contains common functions used in other scripts

setup_logging() {
    local log_type=$1

    # Exit on error
    set -e

    # Create logs directory if it doesn't exist
    if [ ! -d "bash/logs" ]; then
        echo "Creating bash/logs directory..."
        mkdir -p bash/logs || { echo "Failed to create bash/logs directory"; exit 1; }
    fi

    # Add bash/logs directory to .gitignore if not already present
    if ! grep -q "^bash/logs/$" .gitignore; then
        echo "Adding bash/logs directory to .gitignore..."
        echo "bash/logs/" >> .gitignore || { echo "Failed to add bash/logs directory to .gitignore"; exit 1; }
    fi

    # Set log file with timestamp
    LOG_FILE="bash/logs/${log_type}_$(date '+%Y%m%d_%H%M%S').log"
    echo "Logging to $LOG_FILE..."
    exec > >(tee -i "$LOG_FILE") 2>&1
}

# Function to check the status of various components
check_status() {
    # Check Helm status
    echo "Checking Helm status..."
    if helm version &> /dev/null; then
        echo "Helm is installed"
        echo "Helm repositories:"
        helm repo list
    else
        echo "Helm is not installed or not accessible"
    fi

    # Check Docker Volume status
    echo "Checking Docker Volume status..."
    if docker volume ls &> /dev/null; then
        echo "Docker Volumes:"
        docker volume ls
    else
        echo "Docker Volumes are not accessible"
    fi

    # Check Docker Network status
    echo "Checking Docker Network status..."
    if docker network ls &> /dev/null; then
        echo "Docker Networks:"
        docker network ls
    else
        echo "Docker Networks are not accessible"
    fi

    # Check Docker Image status
    echo "Checking Docker Image status..."
    if docker image ls &> /dev/null; then
        echo "Docker Images:"
        docker image ls
    else
        echo "Docker Images are not accessible"
    fi

    # Check Docker Container status
    echo "Checking Docker Container status..."
    if docker ps -a &> /dev/null; then
        echo "Docker Containers:"
        docker ps -a
    else
        echo "Docker Containers are not accessible"
    fi

    # Check Kubernetes cluster status
    echo "Checking Kubernetes cluster status..."
    if kubectl cluster-info &> /dev/null; then
        echo "Kubernetes cluster is running"
        echo "Cluster nodes:"
        kubectl get nodes
        echo "Cluster pods:"
        kubectl get pods --all-namespaces 
    else
        echo "Kubernetes cluster is not running or not accessible"
    fi
}
