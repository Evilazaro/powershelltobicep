param appName string

var loadBalancerName = '${appName}-lb'

resource loadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: loadBalancerName
  location: resourceGroup().location
}
