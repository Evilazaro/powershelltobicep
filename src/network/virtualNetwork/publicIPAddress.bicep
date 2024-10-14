@description('The name of the Public IP Address')
param publicIPAddressName string

@description('The IP Address of the Public IP Address')
param ipAddress string = '172.210.117.56'

@allowed([
  'IPv4'
  'IPv6'
])
@description('The Public IP Address Version')
param publicIPAddressVersion string = 'IPv4'

@allowed([
  'Static'
  'Dynamic'
])
@description('The Public IP Allocation Method')
param publicIPAllocationMethod string = 'Static'

@description('The Idle Timeout in Minutes')
param idleTimeoutInMinutes int = 4

@allowed([
  'Basic'
  'Standard'
])
@description('The SKU of the Public IP Address')
param skuName string = 'Standard'

@allowed([
  'Regional'
  'Global'
])
@description('The Tier of the Public IP Address')
param skuTier string = 'Regional'

@allowed([
  'NoReuse'
  'SubscriptionReuse'
  'ResourceGroupReuse'
  'TenantReuse'
])
@description('The Domain Name Label Scope')
param domainNameLabelScope string = 'SubscriptionReuse'

@allowed([
  'VirtualNetworkInherited'
  'Disabled'
  'Enabled'
])
@description('The Protection Mode of the Public IP Address')
param protectionMode string = 'VirtualNetworkInherited'


@description('Deploy a Public IP Address to Azure')
resource app 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: publicIPAddressName
  location: resourceGroup().location
  sku: {
    name: skuName
    tier: skuTier
  }
  zones: [
    '2'
    '3'
    '1'
  ]
  properties: {
    ipAddress: ipAddress
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
    idleTimeoutInMinutes: idleTimeoutInMinutes
    ipTags: []
    ddosSettings: {
      protectionMode: protectionMode
    }
  }
}
