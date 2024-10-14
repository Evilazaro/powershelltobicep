@description('Name of the Service Bus namespace')
param namespaceName string

@allowed([
  'dev'
  'prod'
])
@description('The environment type for the service bus namespace')
param environmentType string = 'dev'

param tags object = {}

@description('Deploy a Service Bus namespace to Azure')
module serviceBus 'serviceBus.bicep' = {
  name: 'serviceBus'
  params: {
    namespaceName: namespaceName
    environmentType: environmentType
    tags: tags
  }
}

var queueName = '${namespaceName}-queue'

@description('Deploy a Service Bus queue to Azure')
module queue 'serviceBusQueue.bicep' = {
  name: 'serviceBusQueue'
  params: {
    namespaceName: serviceBus.outputs.name
    queueName: queueName
    environmentType: environmentType
  }
  dependsOn: [
    serviceBus
  ]
}

var topicName = '${namespaceName}topic'

@description('Deploy a Service Bus topic to Azure')
module topic 'serviceBusTopic.bicep' = {
  name: 'serviceBusTopic'
  params: {
    namespaceName: serviceBus.outputs.name
    topicName: topicName
    environmentType: environmentType
  }
  dependsOn: [
    serviceBus
  ]
}

