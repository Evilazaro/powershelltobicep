# Define the resource group and template file
$resourceGroupName = "EY-GTP-RG"
$templateFile = "..\serviceBus.bicep"

function CreateQueuesAndTopics {
    param (
        [string]$namespaceName,
        [string]$resourceGroupName
    )

    for ($j = 1; $j -le 10; $j++) {
        $queueName = "queue$j"
        az servicebus queue create --name $queueName --namespace-name $namespaceName --resource-group $resourceGroupName
        az servicebus topic create --name "topic$j" --namespace-name $namespaceName --resource-group $resourceGroupName
        Write-Output "Created queue $queueName"
    }
}

function Deploy-ServiceBus {
    param (
        [string]$resourceGroupName,
        [string]$templateFile,
        [int]$count
    )

    Clear-Host

    try {
        az group create --name $resourceGroupName --location 'westus3'
    
        for ($i = 1; $i -le $count; $i++) {
            $deploymentName = "SB-Deployment-$i"
            $namespaceName = "eygtpsb-$i"
                
            az deployment group create `
                --resource-group $resourceGroupName `
                --name $deploymentName `
                --template-file $templateFile `
                --parameters namespaceName="$namespaceName"
    
            Write-Output "Deployed Service Bus $i"

            CreateQueuesAndTopics -namespaceName $namespaceName -resourceGroupName $resourceGroupName
        }
    }
    catch { 
        Write-Output "An error occurred: $_"
        Write-Output "Deploy failed for Service Bus $i"
    }
}

# Call the function
Deploy-ServiceBus -resourceGroupName $resourceGroupName -templateFile $templateFile -count 10