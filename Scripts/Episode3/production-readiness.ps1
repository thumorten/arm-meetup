## PowerShell Code Snippets for working with Azure RM RBAC

# Search using tags
Find-AzureRmResource -TagName Environment -TagValue Production

# Get the list of all definitions
Get-AzureRmRoleDefinition | Format-Table Name, Description

# List actions of a role
Get-AzureRmRoleDefinition Contributor | Format-List Actions, NotActions

(Get-AzureRmRoleDefinition "Virtual Machine Contributor").Actions

# Get the list of all assignments for a specific RG
Get-AzureRmRoleAssignment -ResourceGroupName arm-meetup-rg | Format-List DisplayName, RoleDefinitionName, Scope

# Get role assignments for a specific user
Get-AzureRmRoleAssignment -SignInName dapazd@microsoft.com | Format-List DisplayName, RoleDefinitionName, Scope

# Get role assignments including the roles that are assigned to the groups to which the user belongs
Get-AzureRmRoleAssignment -SignInName dapazd@microsoft.com -ExpandPrincipalGroups | Format-List DisplayName, RoleDefinitionName, Scope

# list access assignments for the classic subscription administrator and coadministrators
Get-AzureRmRoleAssignment -IncludeClassicAdministrators

# To assign a role, you need to identify both the object (user, group, or application) and the scope.
# get the object ID for an Azure AD group
Get-AzureRmADGroup -SearchString 'WAEPField'
# Note: Group types: Security | Distribution | Office | Mail enabled security

# get the object ID for an Azure AD service principal or application
Get-AzureRmADServicePrincipal -SearchString 'PostmanClient'

# grant access to an application at the subscription scope
New-AzureRmRoleAssignment -ObjectId dbf3d037-57b6-4c11-9f35-3e0034a4c898 -RoleDefinitionName Contributor -Scope /subscriptions/74729c08-12f9-49fc-9817-39e6af4041d1

# grant access to a user at the resource group scope
New-AzureRmRoleAssignment -SignInName dapazd@microsoft.com -RoleDefinitionName 'Contributor' -ResourceGroupName 'arm-meetup-rg'

#  grant access to a group at the resource scope (e.g. WAEPField)
New-AzureRmRoleAssignment -ObjectId 97381e36-bee3-4a83-aa62-d62eb8d67926 -RoleDefinitionName 'Reader' `
    -ResourceName 'devopsSubnet' -ResourceType Microsoft.Network/virtualNetworks/subnets `
    -ParentResource virtualNetworks/devopsVNET -ResourceGroupName k8sjenspin-dev-rg

# remove access for users, groups, and applications
Remove-AzureRmRoleAssignment -ObjectId '<object id>' -RoleDefinitionName '<role name>' -Scope '<scope such as subscription id>'
Remove-AzureRmRoleAssignment -SignInName '<objectId>' -RoleDefinitionName 'Contributor' -ResourceGroupName 'arm-meetup-rg'

# To create a custom role, use the New-AzureRmRoleDefinition command. 
# There are two methods of structuring the role, using PSRoleDefinitionObject or a JSON template.

# check all the available operations for virtual Machine
Get-AzureRMProviderOperation "Microsoft.Compute/virtualMachines/*" | Format-Table OperationName, Operation , Description -AutoSize

# Create role with PSRoleDefinitionObject
# The following example starts with the Virtual Machine Contributor role and uses that to create a custom role 
# called Virtual Machine Operator. The new role grants access to all read operations of Microsoft.Compute, 
# Microsoft.Storage, and Microsoft.Network resource providers and grants access to start, restart, and monitor 
# virtual machines. The custom role can be used in two subscriptions.
$role = Get-AzureRmRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "Virtual Machine Operator"
$role.Description = "Can monitor and restart virtual machines."
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Insights/alertRules/*")
$role.Actions.Add("Microsoft.Support/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/c276fc76-9cd4-44c9-99a7-4fd71546436e")
$role.AssignableScopes.Add("/subscriptions/e91d47c4-76f3-4271-a796-21b4ecfe3624")
New-AzureRmRoleDefinition -Role $role

# Create role with JSON template
# The following example creates a custom role that allows read access to storage and compute 
# resources, access to support, and adds that role to two subscriptions
# Step 1: Create a JSON file - Templates\Episode3\custom-role.json
# Step 2: Run the PSH command
New-AzureRmRoleDefinition -InputFile "C:\Repos\arm-meetup\Templates\Episode3\custom-role.json"

# Modify a custom role
# you can modify an existing custom role using either the PSRoleDefinitionObject or a JSON template
# Option 1: Modify role with PSRoleDefinitionObject
$role = Get-AzureRmRoleDefinition "Virtual Machine Operator"
$role.Actions.Add("Microsoft.Insights/diagnosticSettings/*")
Set-AzureRmRoleDefinition -Role $role

# Option 2: Modify role with JSON template
# Update the JSON template and add the read action for networking as shown in the following example. 
# The definitions listed in the template are not cumulatively applied to an existing definition, 
# meaning that the role appears exactly as you specify in the template. You also need to update 
# the Id field with the ID of the role.
Set-AzureRmRoleDefinition -InputFile "C:\Repos\arm-meetup\Templates\Episode3\custom-role.json"

# Delete a custom role
Get-AzureRmRoleDefinition "Virtual Machine Operator"

Get-AzureRmRoleDefinition "Virtual Machine Operator" | Remove-AzureRmRoleDefinition

# List custom roles
Get-AzureRmRoleDefinition | Format-Table Name, IsCustom





