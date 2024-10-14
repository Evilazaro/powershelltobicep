param clusterName string = uniqueString('aks',resourceGroup().id)
param location string = resourceGroup().location

@allowed([
  'dev'
  'prod'
])
@description('The environment type of the AKS cluster. This will determine the initial pool configuration')
param environmentType string = 'dev'

@description('The initial pool configuration of the AKS cluster')
var initialAgentPoolConfiguration = (environmentType == 'prod') ? {
  name: '${clusterName}-AgentPool'
  count: 3
  mode: 'System'
  vmSkuName: 'Standard_D8ds_v5'
} : {
  name: '${clusterName}-AgentPool'
  count: 1
  mode: 'System'
  vmSkuName: 'Standard_D8ds_v5'
}

@description('The initial pool configuration of the AKS cluster')
var initialUserPoolConfiguration = (environmentType == 'prod') ? {
  name: '${clusterName}-UserPool'
  count: 3
  mode: 'System'
  vmSkuName: 'Standard_D8ds_v5'
} : {
  name: '${clusterName}-UserPool'
  count: 1
  mode: 'User'
  vmSkuName: 'Standard_D8ds_v5'
}

@allowed([
  '1.30.4'
  '1.30.3'
  '1.30.2'
  '1.30.1'
  '1.30.0'
])
@description('The version of Kubernetes to use for the AKS cluster')
param kubernetesVersion string = '1.30.4'

@allowed([
  '1'
  '2'
  '3'
])
@description('The availability zones of the AKS cluster')
param availabilityZones array = [
  '1'
  '2'
  '3'
]

@description('The ID of the cloud services network')
param cloudServicesNetworkId string

@description('The ID of the CNI network')
param cniNetworkId string

@description('Deploy an Azure Kubernetes Service cluster to Azure')
resource aks 'Microsoft.NetworkCloud/kubernetesClusters@2024-06-01-preview' = {
  name: clusterName
  location: location
  extendedLocation: {
    name: location
    type: 'EdgeZone'
  }
  properties:{
    kubernetesVersion: kubernetesVersion
    initialAgentPoolConfigurations: [
      {
        name: initialAgentPoolConfiguration.name
        count: initialAgentPoolConfiguration.count
        mode: initialAgentPoolConfiguration.mode
        vmSkuName: initialAgentPoolConfiguration.vmSkuName
      }
      {
        name: initialUserPoolConfiguration.name
        count: initialUserPoolConfiguration.count
        mode: initialUserPoolConfiguration.mode
        vmSkuName: initialUserPoolConfiguration.vmSkuName
      }
    ]
    controlPlaneNodeConfiguration: {
      vmSkuName: initialAgentPoolConfiguration.vmSkuName
      count: initialAgentPoolConfiguration.count
      availabilityZones: availabilityZones
      administratorConfiguration: {
        adminUsername: '${clusterName}Admin'
      }
    }
    networkConfiguration:{
      cloudServicesNetworkId: cloudServicesNetworkId
      cniNetworkId: cniNetworkId
    }
    administratorConfiguration:{
      adminUsername: '${clusterName}Admin'
    }
    managedResourceGroupConfiguration:{
      name: uniqueString(clusterName,  'managedResourceGroup')
      location: location
    }
  }
}
output clusterName string = aks.name
output location string = aks.location
output kubernetesVersion string = aks.properties.kubernetesVersion
output agentPoolConfiguration array = aks.properties.initialAgentPoolConfigurations
output controlPlaneNodeConfiguration object = aks.properties.controlPlaneNodeConfiguration
output networkConfiguration object = aks.properties.networkConfiguration
output administratorConfiguration object = aks.properties.administratorConfiguration

