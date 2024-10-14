@description('Company Name')
param companyName string

@description('Deploy the Enterprise Level Management Group')
module contosoManagementGroup 'managementGroup.bicep' = {
  name: '${companyName}-ManagementGroup'
  params: {
    parentId: '/providers/Microsoft.Management/managementGroups/Contoso'
    managementGroupName: companyName
    managementGroupDisplayName: '${companyName} Management Group'
  }
}

var landingZoneManagementGroupName = '${companyName}-LandingZone'

@description('Deploy the Landing Zone Management Group')
module landingZoneManagementGroup 'managementGroup.bicep' = {
  name: '${companyName}-LandingZoneManagementGroup'
  params: {
    parentId: contosoManagementGroup.outputs.rootManagementGroupId
    managementGroupName: landingZoneManagementGroupName
    managementGroupDisplayName: '${companyName} Landing Zone Management Group'
  }
}
