# Episode 3 - New CISO arrives


# Task 1 - limit number of Onwers on the subscription level
$CurrentOwners = Get-AzureRmRoleAssignment -RoleDefinitionName 'Owner' | Format-Table DisplayName, ObjectId, ObjectType

foreach ($Owner in $CurrentOwners) {
    If ($Owner.ObjectId -ne '066ff619-4eff-4660-ae3d-68bfb1d2f91c') {
        New-AzureRmRoleAssignment -ObjectId $Owner.ObjectId -RoleDefinitionName 'Contributor' -Scope /subscriptions/74729c08-12f9-49fc-9817-39e6af4041d1
        Remove-AzureRmRoleAssignment -ObjectId $Owner.ObjectId -RoleDefinitionName 'Owner' -Scope /subscriptions/74729c08-12f9-49fc-9817-39e6af4041d1
    }
}

# Task 2 - Find production resources and apply 'DoNotDelete' lock
# Ref. https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/new-azurermresourcelock?view=azurermps-5.4.0
$ProductionResources = Find-AzureRmResource -TagName Environment -TagValue Production

foreach ($Resource in $ProductionResources) {
    New-AzureRmResourceLock -LockLevel CanNotDelete -LockNotes "Applied 0801 by dapazd" -LockName "CannotDeleteProdLock" -ResourceName $Resource.Name -ResourceType $Resource.ResourceType -ResourceGroupName $Resource.ResourceGroupName -Force
}

# Task 4 - Policy for EU Data location
# Ref. https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/get-azurermpolicydefinition?view=azurermps-5.4.0

$Policy = Get-AzureRmPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations audit' -and $_.Properties.PolicyType -eq 'Custom'}
$Locations = Get-AzureRmLocation | Where-Object displayname -like "*Europe*"
$AllowedLocations = @{"allowedLocations"=($Locations.location)}
$Sku = @{name=A1; tier=Standard}
New-AzureRmPolicyAssignment -Name "RestrictLocationPolicyAssignment" -PolicyDefinition $Policy -Scope /subscriptions/74729c08-12f9-49fc-9817-39e6af4041d1 -PolicyParameterObject $AllowedLocations -Sku $Sku




