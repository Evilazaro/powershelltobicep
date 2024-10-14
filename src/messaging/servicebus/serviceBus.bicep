@description('The name of the Service Bus namespace')
param namespaceName string

@allowed([
  'dev'
  'prod'
])
@description('The environment type for the service bus namespace')
param environmentType string = 'dev'

var sku = environmentType == 'dev' ? {
  name: 'Standard'
  tier: 'Standard'
} : {
  name: 'Premium'
  tier: 'Premium'
}

@description('Deploy a Service Bus namespace to Azure')
resource serviceBus 'Microsoft.ServiceBus/namespaces@2023-01-01-preview' = {
  name: namespaceName
  location: resourceGroup().location
  sku: sku
  tags: {
    environmentType: environmentType
    division: 'Tax'
  }
}

@description('The service bus namespace name')
output name string = serviceBus.name

@description('The service bus namespace resource')
output serviceBus object = serviceBus

@description('The service bus namespace sku')
output sku object = sku


