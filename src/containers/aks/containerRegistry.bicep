
@description('Name of the Azure Container Registry')
param containerRegistryName string

@allowed([
  'Basic'
  'Standard'
])
@description('The SKU of the Azure Container Registry')
param skuName string = 'Basic'

@allowed([
  'SystemAssigned'
  'UserAssigned'
])
@description('The identity type of the Azure Container Registry')
param identityType string = 'SystemAssigned'


@description('Create an Azure Container Registry')
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: resourceGroup().location
  sku: {
    name: skuName
  }
  identity: {
    type: identityType
  }	
}
