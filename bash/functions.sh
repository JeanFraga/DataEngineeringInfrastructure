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