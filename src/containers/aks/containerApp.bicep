param containerAppName string
param userAssignedIdentityId object
param tags object = {}

@allowed([
  'SystemAssigned'
  'UserAssigned'
])
@description('The identity type of the container app')
param identityType string = 'SystemAssigned'

@description('Deploy a container app to Azure')
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: resourceGroup().location
  properties: {}
  identity: {
    type: identityType
    userAssignedIdentities: userAssignedIdentityId
  }
  tags: tags
}
