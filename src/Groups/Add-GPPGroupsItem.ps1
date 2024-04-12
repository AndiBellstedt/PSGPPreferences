function Add-GPPGroupsItem {
    <#
    .SYNOPSIS
        A function to add a Group Policy Preference (GPP) groups item to a Group Policy Object (GPO).

    .DESCRIPTION
        The function adds a GPP groups item to a GPO.
        It uses the `Convert-GPONameToID`, `Get-GPPSection`, and `Set-GPPSection` functions
        to perform the operation.

    .PARAMETER InputObject
        The GPP groups item to add.
        This parameter is mandatory and can be specified by either name or ID.

    .PARAMETER GPOName
        The name of the GPO where the GPP groups item will be added.
        This parameter is mandatory when specifying the GPP groups item by name.

    .PARAMETER GPOId
        The ID of the GPO where the GPP groups item will be added.
        This parameter is mandatory when specifying the GPP groups item by ID.

    .PARAMETER Context
        The context in which the GPP groups item should be added.
        If not specified, the function will use the module-wide default GPP context.

    .PARAMETER DomainName
        The name of the domain where the GPO resides.
        This parameter is optional.

    .EXAMPLE
        PS C:\> Add-GPPGroupsItem -InputObject $groupsItem -GPOName "TestGPO"

        This example creates a new GPP groups from $groupsItem and adds it to a GPO named "TestGPO".
        $groupsItem can be defined like this:
        PS C:\> $groupsItem = New-GPPItemGroupsSection -Name "TestGroupsItem"

    .EXAMPLE
        PS C:\> Add-GPPGroupsItem -InputObject $groupsItem -GPOId "87654321-4321-4321-4321-210987654321"

        This example creates a new GPP groups from $groupsItem and adds it to a GPO with the ID "87654321-4321-4321-4321-210987654321".
        $groupsItem can be defined like this:
        PS C:\> $groupsItem = New-GPPItemGroupsSection -Id "12345678-1234-1234-1234-123456789012"
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [GPPItemGroupsSection]
        $InputObject,

        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ById')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [string]
        $DomainName
    )

    if (-not $GPOId) {
        if ($DomainName) {
            $GPOId = Convert-GPONameToID -Name $GPOName -DomainName $DomainName
        } else {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }
    }

    if ($DomainName) {
        $gppSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
    } else {
        $gppSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }

    if ($gppSection) {
        $gppSection.Members.Add($InputObject)
    } else {
        $gppSection = [GPPSectionGroups]::new($InputObject, $false)
    }

    if ($DomainName) {
        Set-GPPSection -InputObject $gppSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
    } else {
        Set-GPPSection -InputObject $gppSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
}