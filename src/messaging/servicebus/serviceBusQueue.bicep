@description('Namespace name of the Service Bus')
param namespaceName string

@description('Queue name of the Service Bus Queue')
param queueName string

@allowed([
  'dev'
  'prod'
])
@description('The environment type for the service bus namespace')
param environmentType string = 'dev'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2023-01-01-preview' existing = {
  name: namespaceName
}

@description('The default configuration for a Service Bus queue')
var defaultQueueConfig = (environmentType == 'dev') ?  {
  MaxSizeInMegabytes: 1024
  LockDuration: 'PT1M'
  EnablePartitioning: false
  RequiresDuplicateDetection: false
  DuplicateDetectionHistoryTimeWindow: 'PT10M'
  EnableBatchedOperations: true
  DeadLetteringOnMessageExpiration: false
  Status: 'Active'
}
: {
  MaxSizeInMegabytes: 2048
  LockDuration: 'PT1M'
  EnablePartitioning: false
  RequiresDuplicateDetection: false
  DuplicateDetectionHistoryTimeWindow: 'PT10M'
  EnableBatchedOperations: true
  DeadLetteringOnMessageExpiration: false
  Status: 'Active'
}

@description('Deploy a Service Bus queue to Azure')
resource queue 'Microsoft.ServiceBus/namespaces/queues@2023-01-01-preview' = {
  parent: serviceBus
  name: queueName
  properties: {
    maxSizeInMegabytes: defaultQueueConfig.MaxSizeInMegabytes
    lockDuration: defaultQueueConfig.LockDuration
    enablePartitioning: defaultQueueConfig.EnablePartitioning
    requiresDuplicateDetection: defaultQueueConfig.RequiresDuplicateDetection
    duplicateDetectionHistoryTimeWindow: defaultQueueConfig.DuplicateDetectionHistoryTimeWindow
    enableBatchedOperations: defaultQueueConfig.EnableBatchedOperations
    deadLetteringOnMessageExpiration: defaultQueueConfig.DeadLetteringOnMessageExpiration
    status: defaultQueueConfig.Status
  }
}

@description('The Service Bus queue name')
output name string = queue.name

@description('Queue URL')
output queueUrl string = queue.id

