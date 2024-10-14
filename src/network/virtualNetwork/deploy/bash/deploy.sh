#!/bin/bash

set -euo pipefail

# Variables
resourceGroup='virtualNetworkRg'
location='eastus'

# Function to create resource group
createResourceGroup() {
    echo "Creating resource group: $resourceGroup in location: $location"
    az group create --name "$resourceGroup" --location "$location"
}

# Function to deploy virtual network
deployVirtualNetwork() {

    echo "Building bicep file"
    az bicep build -f ../../virtualNetwork.bicep

    if [ $? -ne 0 ]; then
        echo "Failed to build bicep file"
        exit 1
    fi

    echo "Deploying virtual network in resource group: $resourceGroup"
    az deployment group create \
        --resource-group "$resourceGroup" \
        --template-file ../../deployAllNetwork.bicep \
        --parameters appName='eyraptor' 
        

    if [ $? -ne 0 ]; then
        echo "Failed to deploy virtual network"
        exit 1
    fi
}


# Main script execution
createResourceGroup
deployVirtualNetwork

# Uncomment the following line to delete the resource group after deployment
# az group delete --name "$resourceGroup" --yes --no-wait