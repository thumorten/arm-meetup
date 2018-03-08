## Code snippets for working with ARM deployments

# Lists available RPs with registration status
Get-AzureRmResourceProvider -ListAvailable | Select-Object ProviderNamespace, RegistrationState
# Register a RP
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch

# Get resource types for a resource provider
(Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes.ResourceTypeName

# Get the available API versions for a resource type
((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).ApiVersions

# Get supported locations for a resource type
((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).Locations

# Get all deployments for a resource group
Get-AzureRmResourceGroupDeployment -ResourceGroupName "k8sjenspin-dev-rg"
# Output structure (objects): 
# DeploymentName, ResourceGroupName, ProvisioningState, Timestamp, Mode, 
# TemplateLink, Parameters (Name, Type, Value), Outputs (Name, Type, Value), DeploymentDebugLogLevel


# Get a deployment by name
Get-AzureRmResourceGroupDeployment -ResourceGroupName "k8sjenspin-dev-rg" -Name "Microsoft.Template"
# Outputs: Microsoft.Azure.Commands.ResourceManagement.Models.PSResourceGroupDeployment

# Validate a resource group deployment:
# The Test-AzureRmResourceGroupDeployment cmdlet determines whether an Azure resource group deployment
# template and its parameter values are valid.
Test-AzureRmResourceGroupDeployment -ResourceGroupName "k8sjenspin-dev-rg" -TemplateFile "azuredeploy.json"

$ParamsHashTable = @{}
Test-AzureRmResourceGroupDeployment -ResourceGroupName "k8sjenspin-dev-rg" -TemplateFile "azuredeploy.json" -TemplateParameterObject $ParamsHashTable

Test-AzureRmResourceGroupDeployment -ResourceGroupName "k8sjenspin-dev-rg" -TemplateUri "https://anyURL" -TemplateParameterObject $ParamsHashTable

# Export a deployment to a template
Export-AzureRmResourceGroup -ResourceGroupName "k8sjenspin-dev-rg" -Path c:\temp -IncludeParameterDefaultValue -IncludeComments
# Note: There might be some cases where this cmdlet fails to generate some parts of the template. 
# Warning messages will inform you of the resources that failed. 
# The template will still be generated for the parts that were successful.

# Get deployment operations for a particular deployment
Get-AzureRmResourceGroupDeploymentOperation -DeploymentName 'Microsoft.Template' -ResourceGroupName 'k8sjenspin-dev-rg'
# lists all the operations that were part of a deployment to help you identify and give more information about 
# the exact operations that failed for a particular deployment. It can also show the response and the request 
# content for each deployment operation.
