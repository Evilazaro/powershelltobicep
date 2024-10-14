param managementGroupName string 
param managementGroupDisplayName string
param parentId string

resource rootManagementGroup 'Microsoft.Management/managementGroups@2023-04-01' existing = {
  name: 'Tenant Root Group'
  scope: tenant()
}

output rootManagementGroupId string = rootManagementGroup.id
output rootManagementGroupName string = rootManagementGroup.name
output rootManagementGroupDisplayName string = rootManagementGroup.properties.displayName
output rootManagementGroupParentId string = rootManagementGroup.properties.details.parent.id


resource managementGroup 'Microsoft.Management/managementGroups@2023-04-01' = { 
  name: managementGroupName
  scope: tenant()
  properties: {
    displayName: managementGroupDisplayName
    details: {
      parent: {
        parentId: rootManagementGroup.properties.details.parent.id
      }
    }
  }
}

@description('Management Group Name')
output managementGroupName string = managementGroup.name
