#!/bin/bash

set -euo pipefail

# Variables
resourceGroup='managementGroupRg'
location='eastus'

# Function to create resource group
createResourceGroup() {
    echo "Creating resource group: $resourceGroup in location: $location"
    az group create --name "$resourceGroup" --location "$location"
}

# Function to deploy management group
deployVirtualNetwork() {

    echo "Building bicep file"
    az bicep build -f ./deployFoundationLandingZone.bicep

    if [ $? -ne 0 ]; then
        echo "Failed to build bicep file"
        exit 1
    fi

    echo "Deploying management group in resource group: $resourceGroup"
    az deployment group create \
        --resource-group "$resourceGroup" \
        --template-file ./deployFoundationLandingZone.bicep   \
        --parameters companyName='BRSolucoes'     

    if [ $? -ne 0 ]; then
        echo "Failed to deploy management group"
        exit 1
    fi
}


# Main script execution
createResourceGroup
deployVirtualNetwork

# Uncomment the following line to delete the resource group after deployment
# az group delete --name "$resourceGroup" --yes --no-wait