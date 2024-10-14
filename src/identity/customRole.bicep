@description('The name of the app the custom role is being created for')
param appName string

// Replace the assignableScopes variable with the assignable scopes of the custom role
@description('The assignable scopes of the custom role')
var assignableScopes = [
  '/subscriptions/00000000-0000-0000-0000-000000000000'
]

// Replace the permissions variable with the permissions of the custom role
@description('The permissions of the custom role')
var permissions = [
  {
    actions: [
      'Microsoft.Storage/storageAccounts/read'
      'Microsoft.Storage/storageAccounts/write'
    ]
    notActions: []
    dataActions: []
    notDataActions: []
  }
  {
    actions: [
      'Microsoft.Network/virtualNetworks/read'
      'Microsoft.Network/virtualNetworks/write'
    ]
    notActions: []
    dataActions: []
    notDataActions: []
  }
]

@description('The name of the custom role')
var customRoleName = '${appName}-custom-role'

@description('The description of the custom role')
var customRoleDescription = 'Custom role for ${appName}'

@description('Create a custom role in Azure')
resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: customRoleName
  properties: {
    roleName: customRoleName
    description: customRoleDescription
    assignableScopes: assignableScopes
    permissions: permissions
    type: 'CustomRole'
  }
}
