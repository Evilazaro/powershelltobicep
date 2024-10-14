# Define the resource group and template file
$resourceGroupName = "EY-GTPBicep-RG"

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

            az deployment group create `
                --resource-group $resourceGroupName `
                --name "$namespaceName-$queueName-deployment" `
                --template-file "..\serviceBusQueue.bicep" `
                --parameters namespaceName="$namespaceName" queueName="$queueName" --output none

            Write-Output "Created queue $queueName"

            Wait-ForUserResponse
            
            $topicName = "topic$j"

            write-output "Creating topic $topicName"

            $resultTopic = $(az deployment group create `
                --resource-group $resourceGroupName `
                --name "$namespaceName-$topicName-deployment" `
                --template-file "..\serviceBusTopic.bicep" `
                --parameters namespaceName="$namespaceName" topicName="$topicName" --output none) 

            Write-Output "Created topic $topicName and it has the following properties: $($resultTopic | ConvertFrom-Json)"

            Wait-ForUserResponse
        }
    }
    catch {
        Write-Output "An error occurred: $_"
        Write-Output "Parameters: NamespaceName=$namespaceName, ResourceGroupName=$resourceGroupName, Count=$count"
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
            $namespaceName = "gtpbicep$i"
            
            Write-Output "Deploying Service Bus $namespaceName"

            az deployment group create `
                --resource-group $resourceGroupName `
                --name "SB-$namespaceName-deployment" `
                --template-file "..\serviceBus.bicep" `
                --parameters namespaceName="$namespaceName" --output none
    
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