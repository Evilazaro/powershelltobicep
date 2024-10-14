@description('The name of the storage account')
@maxLength(21)
@minLength(3)
param storageAccountName string

@description('The location where the storage account will be created')
param location string = resourceGroup().location

@allowed([
  'dev'
  'prod'
])
param environmentType string = 'dev'

@description('The access tier of the storage account')
@allowed([
  'Hot'
  'Cool'
])
param accesTier string = 'Hot'

@description('The tags of the storage account')
param tags object = {
  
}

// Allowed values
// 'Standard_LRS'
// 'Standard_GRS'
// 'Standard_RAGRS'
// 'Standard_ZRS'
// 'Premium_LRS'
// 'Premium_ZRS'
@description('The SKU of the storage account')
var sku = (environmentType == 'dev') ? 'Standard_LRS' : 'Premium_ZRS'

// Allowed values
// 'StorageV2'
// 'Storage'
// 'BlobStorage'
@description('The kind of the storage account')
var kind = 'StorageV2'

@description('Deploy a storage account to Azure with a unique name')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accesTier
  }
  tags: tags
}

