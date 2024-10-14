# Define the resource group and template file
$resourceGroupName = "EY-GTPCLI-RG"

function CreateQueuesAndTopics {
    param (
        [string]$namespaceName,
        [string]$resourceGroupName,
        [int]$count
    )

    for ($j = 1; $j -le $count; $j++) {
        $queueName = "queue$j"

        write-output "Creating queue $queueName"

        az servicebus queue create --name $queueName --namespace-name $namespaceName --resource-group $resourceGroupName --only-show-errors --output none
        Write-Output "Created queue $queueName"

        write-output "Creating topic topic$j"
        
        az servicebus topic create --name "topic$j" --namespace-name $namespaceName --resource-group $resourceGroupName --only-show-errors --output none
        Write-Output "Created topic topic$j"

        Wait-ForUserResponse

        CreateSubscriptions -namespaceName $namespaceName -resourceGroupName $resourceGroupName -topicName "topic$j" -count $count

        Write-Output "Created queue $queueName"
    }
}


function CreateSubscriptions {
    param (
        [string]$namespaceName,
        [string]$resourceGroupName,
        [string]$topicName,
        [int]$count
    )

    try {

        for ($k = 1; $k -le $count; $k++) {
            $subscriptionName = "subscription$k"

            write-output "Creating subscription $subscriptionName for topic $topicName"

            az servicebus topic subscription create --name $subscriptionName --topic-name "$topicName" --namespace-name $namespaceName --resource-group $resourceGroupName --only-show-errors --output none
            Write-Output "Created subscription $subscriptionName for topic $topicName"

            Wait-ForUserResponse

            ManageSubscriptionRule -namespaceName $namespaceName -resourceGroupName $resourceGroupName -topicName "$topicName" -subscriptionName "$subscriptionName" -sqlExpression "1=1"
        }

    }
    catch {
        Write-Output "An error occurred: $_"
        Write-Output "Failed to create subscription $subscriptionName for topic $topicName in the namespace $namespaceName"
    }
}

function Deploy-ServiceBus {
    param (
        [string]$resourceGroupName,
        [int]$count
    )

    Clear-Host

    try {
        az group create --name $resourceGroupName --location 'westus3'
    
        for ($i = 1; $i -le $count; $i++) {
            $namespaceName = "gtpcli$i"

            Write-Output "Deploying Service Bus $namespaceName"
                
            az servicebus namespace create --name $namespaceName --resource-group $resourceGroupName --location 'westus3' --sku 'Standard' --only-show-errors --output none
    
            Write-Output "Deployed Service Bus $namespaceName"

            Wait-ForUserResponse

            CreateQueuesAndTopics -namespaceName $namespaceName -resourceGroupName $resourceGroupName -count $count
        }

    }
    catch { 
        Write-Output "An error occurred: $_"
        Write-Output "Deploy failed for Service Bus $i"
    }
}

function ManageSubscriptionRule {
    param (
        [string]$namespaceName,
        [string]$resourceGroupName,
        [string]$topicName,
        [string]$subscriptionName,
        [string]$sqlExpression
    )
    
    $returnedValue = ""
    try {
        Write-Output "Creating Rule-0 for subscription $subscriptionName in topic $topicName"
        $returnedValue = $(az servicebus topic subscription rule create `
                --name 'Rule-0' `
                --namespace-name $namespaceName `
                --resource-group $resourceGroupName `
                --topic-name $topicName `
                --subscription-name $subscriptionName `
                --filter-sql-expression $sqlExpression)
 
        if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }
        
        Write-Output "Rule-0 created for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue"

        Wait-ForUserResponse
 
        Write-Output "Deleting the default rule for subscription $subscriptionName in topic $topicName"
        $returnedValue = $(az servicebus topic subscription rule delete `
                --name '$Default' `
                --namespace-name $namespaceName `
                --resource-group $resourceGroupName `
                --topic-name $topicName `
                --subscription-name $subscriptionName)
 
       if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }

        Write-Output "Default rule deleted for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue" 

        Wait-ForUserResponse
 
        Write-Output "Creating Rule-1 for subscription $subscriptionName in topic $topicName"
        $returnedValue = $(az servicebus topic subscription rule create `
                --name 'Rule-1' `
                --namespace-name $namespaceName `
                --resource-group $resourceGroupName `
                --topic-name $topicName `
                --subscription-name $subscriptionName `
                --filter-sql-expression $sqlExpression)

       if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }
     
        Write-Output "Rule-1 created for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue"

        Wait-ForUserResponse
 
        Write-Output "Deleting Rule-0 for subscription $subscriptionName in topic $topicName"
        $returnedValue = $(az servicebus topic subscription rule delete `
                --name 'Rule-0' `
                --namespace-name $namespaceName `
                --resource-group $resourceGroupName `
                --topic-name $topicName `
                --subscription-name $subscriptionName)

       if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }
 
        Write-Output "Rule-0 deleted for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue"

        Wait-ForUserResponse
    }
    catch {
        Write-Output "An error occurred: $_"
    }
 
}

function Wait-ForUserResponse {

    $response = Read-Host "Press Enter to continue or type 'exit' to stop"

    if ($response -eq 'exit') {
        Write-Output "Execution stopped by the user."
        exit
    }

    Clear-Host
}

# Call the function
Deploy-ServiceBus -resourceGroupName $resourceGroupName -count 1

