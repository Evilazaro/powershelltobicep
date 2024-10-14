#!/bin/bash

set -euo pipefail

# Variables
resourceGroup='servicebus-rg'
location='eastus'

# Function to create resource group
createResourceGroup() {
    echo "Creating resource group: $resourceGroup in location: $location"
    az group create --name "$resourceGroup" --location "$location"
}

# Function to deploy service bus
deployStorageAccount() {

    echo "Building bicep file"
    az bicep build -f ../deployServiceBus.bicep

    if [ $? -ne 0 ]; then
        echo "Failed to build bicep file"
        exit 1
    fi

    tags="{'environment':'dev','department':'IT'}"

    echo "Deploying service bus in resource group: $resourceGroup"
    az deployment group create \
        --resource-group "$resourceGroup" \
        --template-file ../deployServiceBus.bicep \
        --parameters namespaceName='eyraptors' \
            tags="$tags"
            
    if [ $? -ne 0 ]; then
        echo "Failed to deploy service bus"
        exit 1
    fi
}


clear
createResourceGroup
deployStorageAccount