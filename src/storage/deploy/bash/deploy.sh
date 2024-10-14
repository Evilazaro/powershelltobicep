#!/bin/bash

set -euo pipefail

# Variables
resourceGroup='storageRg'
location='eastus'

# Function to create resource group
createResourceGroup() {
    echo "Creating resource group: $resourceGroup in location: $location"
    az group create --name "$resourceGroup" --location "$location"
}

# Function to deploy storage account
deployStorageAccount() {

    echo "Building bicep file"
    az bicep build -f ../../storageAccount.bicep

    if [ $? -ne 0 ]; then
        echo "Failed to build bicep file"
        exit 1
    fi

    tags="{'environment':'dev','department':'IT'}"

    echo "Deploying storage account in resource group: $resourceGroup"
    az deployment group create \
        --resource-group "$resourceGroup" \
        --template-file ../../storageAccount.bicep \
        --parameters appName='eyraptors' \
                    location="$location" \
                    tags="$tags"

    if [ $? -ne 0 ]; then
        echo "Failed to deploy storage account"
        exit 1
    fi
}


# Main script execution
createResourceGroup
deployStorageAccount

# Uncomment the following line to delete the resource group after deployment
# az group delete --name "$resourceGroup" --yes --no-wait