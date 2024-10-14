@description('Managed Identity Name')
param appName string

@description('Deploy a managed identity to Azure')
var managedIdentityName = '${appName}-mi'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location
}
