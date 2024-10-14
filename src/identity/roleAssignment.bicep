@description('The name of the app the role assignment is being created for')
param appName string

@description('The name of the Managed Identity')
param managedIdentityName string

@description('The role definition ID for the role assignment')
param roleDefinitionId string

@description('Create a role assignment for a principal in a resource group')
var roleAssignmentName = '${appName}-role-assignment'

@description('Get the principal ID of the Managed Identity')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdentityName
}

@description('Assign a role to a principal in a resource group')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleDefinitionId
  }
}
