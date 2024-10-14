@description('Name of an Existent Virtual Network')
param virtualNetworkName string

@description('Existent Subnet to Deploy a Network Interface')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

@description('Deploy a Network Interface to Azure')
resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: '${virtualNetworkName}-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: null
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}
