#!/bin/bash

# This script contains common functions used in other scripts

setup_logging() {
    local log_type=$1

    # Exit on error
    set -e

    # Create logs directory if it doesn't exist
    if [ ! -d "logs" ]; then
        echo "Creating logs directory..."
        mkdir -p logs
    fi

    # Add logs directory to .gitignore if not already present
    if ! grep -q "^logs/$" .gitignore; then
        echo "Adding logs directory to .gitignore..."
        echo "logs/" >> .gitignore
    fi

    # Set log file with timestamp
    LOG_FILE="logs/${log_type}_$(date '+%Y%m%d_%H%M%S').log"
    echo "Logging to $LOG_FILE..."
    exec > >(tee -i "$LOG_FILE") 2>&1
}