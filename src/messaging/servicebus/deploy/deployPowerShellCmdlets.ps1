# Define the resource group and template file
$resourceGroupName = "EY-GTPCMD-RG"

# Import the Az module
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}

function CreateQueuesAndTopics {
    param (
        [string]$namespaceName,
        [string]$resourceGroupName,
        [int]$count
    )

    try {
        for ($j = 1; $j -le $count; $j++) {
            $queueName = "queue$j"

            write-output "Creating queue $queueName"

            New-AzServiceBusQueue -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -Name $queueName
            Write-Output "Created queue $queueName"
            
            $topicName = "topic$j"

            write-output "Creating topic $topicName"

            New-AzServiceBusTopic -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -Name $topicName
            Write-Output "Created topic $topicName"

            Wait-ForUserResponse
    
            CreateSubscriptions -NamespaceName $namespaceName -resourceGroupName $resourceGroupName -topicName $topicName -count $count
        }
    }
    catch {
        Write-Output "An error occurred: $_"
        Write-Output "Parameters: NamespaceName=$namespaceName, ResourceGroupName=$resourceGroupName, Count=$count"
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

            New-AzServiceBusSubscription -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -TopicName $topicName -Name $subscriptionName
            Write-Output "Created subscription $subscriptionName for topic $topicName"

            Wait-ForUserResponse

            ManageSubscriptionRule -NamespaceName $namespaceName -resourceGroupName $resourceGroupName -topicName $topicName -subscriptionName $subscriptionName -sqlExpression "1=1"
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
        New-AzResourceGroup -Name $resourceGroupName -Location 'westus3'
    
        for ($i = 1; $i -le $count; $i++) {
            $namespaceName = "gtpcmd$i"

            Write-Output "Deploying Service Bus $namespaceName"
                
            New-AzServiceBusNamespace -ResourceGroupName $resourceGroupName -Name $namespaceName -SkuName 'Standard' -Location 'westus3'
    
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
        $returnedValue = New-AzServiceBusRule -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -TopicName $topicName -SubscriptionName $subscriptionName -Name 'Rule-0' -SqlExpression $sqlExpression
 
        if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }
        
        Write-Output "Rule-0 created for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue"

        Wait-ForUserResponse
 
        Write-Output "Deleting the default rule for subscription $subscriptionName in topic $topicName"
        $returnedValue = Remove-AzServiceBusRule -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -TopicName $topicName -SubscriptionName $subscriptionName -Name '$Default'
 
        if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }

        Write-Output "Default rule deleted for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue" 

        Wait-ForUserResponse
 
        Write-Output "Creating Rule-1 for subscription $subscriptionName in topic $topicName"
        $returnedValue = New-AzServiceBusRule -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -TopicName $topicName -SubscriptionName $subscriptionName -Name 'Rule-1' -SqlExpression $sqlExpression

        if ($null -eq $returnedValue -or $returnedValue -eq "") {
            $returnedValue = "NULL"
        }
        else {
            $returnedValue = "NOT NULL"
        }
     
        Write-Output "Rule-1 created for subscription $subscriptionName in topic $topicName and its returned value is $returnedValue"

        Wait-ForUserResponse
 
        Write-Output "Deleting Rule-0 for subscription $subscriptionName in topic $topicName"
        $returnedValue = Remove-AzServiceBusRule -ResourceGroupName $resourceGroupName -NamespaceName $namespaceName -TopicName $topicName -SubscriptionName $subscriptionName -Name 'Rule-0'

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

    # $response = Read-Host "Press Enter to continue or type 'exit' to stop"

    # if ($response -eq 'exit') {
    #     Write-Output "Execution stopped by the user."
    #     exit
    # }

    # Clear-Host
}

# Call the function
Deploy-ServiceBus -resourceGroupName $resourceGroupName -count 1