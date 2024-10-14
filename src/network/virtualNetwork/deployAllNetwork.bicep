param appName string 

@description('The name of the virtual network')
var virtualNetworkName = '${appName}-vnet'

@description('Deploy a Virtual Network to Azure')
module virtualNetwork './virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    virtualNetworkName: virtualNetworkName
  }
}

@description('The security rules of the network security group')
var securityRules = [
  {
    name: 'Allow-SSH'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-HTTP'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-HTTPS'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
]

@description('The name of the network security group')
var nsgName = '${appName}-nsg'

@description('Deploy a Network Security Group to Azure')
module nsg '../../security/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    nsgName: nsgName
    securityRules: securityRules
    tags: {}
  }
}

@description('Deploy a Subnet to Azure')
module subnet './subNet.bicep' = {
  name: 'subnet'
  params: {
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
    nsgId: nsg.outputs.nsgId
  }
  dependsOn: [
    virtualNetwork
    nsg
  ]
}

module networkInterface './networkInterface.bicep' = {
  name: 'networkInterface'
  params: {
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
  }
  dependsOn: [
    virtualNetwork
    subnet
  ]
}

var publicIPAddressName = '${appName}-ip'
module publicIPAddress './publicIPAddress.bicep' = {
  name: 'publicIPAddress'
  params: {
    publicIPAddressName: publicIPAddressName
  }
  dependsOn: [
    virtualNetwork
    networkInterface
  ]
}
