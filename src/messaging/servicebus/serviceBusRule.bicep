@description('Service Bus Topic Subscription Name')
param subscriptionName string

@description('Service Bus Rule Name')
param ruleName string

@description('Existent Service Bus Topic Subscription')
resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2023-01-01-preview' existing = {
  name: subscriptionName
}

@description('Deploy a Service Bus Rule')
resource serviceBusRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2023-01-01-preview' = {
  name: ruleName
  parent: subscription
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: 'myProperty = @myValue'
    }
  }
}
