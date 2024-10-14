param name string
param topicName string

@description('Name of an existent Topic')
resource topic 'Microsoft.ServiceBus/namespaces/topics@2023-01-01-preview' existing = {
  name: topicName
}

@description('Deploys a new Subscription for the Topic')
resource topicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2023-01-01-preview' = {
  name: name
  parent: topic
}

@description('The name of the Subscription')
output subscriptionName string = topicSubscription.name

@description('Subscription Id')
output subscriptionId string = topicSubscription.id

@description('Subscription Rule')
resource subscriptionRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2023-01-01-preview' = {
  name: 'Rule-1'
  parent: topicSubscription
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: '1=1'
    }
  }
}

@description('Subscription Rule Id')
output subscriptionRuleId string = subscriptionRule.id

@description('Subscription Rule Name')
output subscriptionRuleName string = subscriptionRule.name
