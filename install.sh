#!/bin/bash

# This script installs necessary tools and dependencies for MLOps components
# It also checks the installation status of the tools and dependencies

# if [ "$EUID" -ne 0 ]; then
#   echo "Please run as root"
#   exit 1
# fi

# Create logs directory if it doesn't exist
mkdir -p logs
echo "logs/" >> .gitignore 2>/dev/null

# Set log file with timestamp
LOG_FILE="logs/install_$(date '+%Y%m%d_%H%M%S').log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Exit on error
set -e

# Check for required command line tools
echo "Checking for required CLI tools..."
for tool in git aws az gcloud helm kubectl terraform ansible; do
    if ! command -v $tool &> /dev/null; then
        echo "Warning: $tool is not installed"
    else
        echo "$tool is installed: $($tool --version)"
    fi
done

# Update package list
# Detect OS and update package list
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Updating package list for macOS..."
    if command -v brew &> /dev/null; then
        brew update
    else
        echo "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/debian_version ]]; then
        echo "Updating package list for Debian-based Linux..."
        sudo apt-get update
    elif [[ -f /etc/redhat-release ]]; then
        echo "Updating package list for RedHat-based Linux..."
        sudo yum update
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    echo "Windows detected. Package management not supported."
    echo "Please ensure you have package manager (like Chocolatey) installed manually."
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask docker # Install Docker Desktop
    else
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    fi
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker-compose
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
fi

# Install and check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install kubectl
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
        echo "Windows detected. Please install kubectl manually."
        exit 1
    else
        echo "Unsupported OS for kubectl installation: $OSTYPE"
        exit 1
    fi
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

# Pull necessary Docker images
echo "Pulling necessary Docker images..."
docker pull postgres:latest # For metadata storage
docker pull apache/airflow:latest # For workflow orchestration
docker pull apache/nifi:latest # For data ingestion
docker pull confluentinc/cp-kafka:latest # For event streaming
docker pull confluentinc/cp-zookeeper:latest # For event streaming
docker pull redis:latest # For caching
docker pull apache/spark-py:latest # For data processing
docker pull jupyter/pyspark-notebook:latest # For data exploration
# Pull MLOps-specific containers
echo "Pulling MLOps-specific containers..."
docker pull minio/minio:latest  # For model artifact storage
docker pull mysql:8.0  # For ML metadata storage
docker pull jenkins/jenkins:lts  # For CI/CD pipelines
docker pull grafana/grafana:latest  # For metrics visualization
docker pull prom/prometheus:latest  # For metrics collection
docker pull ghcr.io/mlflow/mlflow:latest  # For ML experiment tracking
docker pull tensorflow/serving:latest  # For model serving

# Create docker network if it doesn't exist
docker network create data-engineering-network 2>/dev/null || true

# Check available disk space
echo "Checking available disk space..."
df -h /

echo "MLOps components installation and checks completed!"