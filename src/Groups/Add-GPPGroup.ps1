function Add-GPPGroup {
    <#
    .SYNOPSIS
        Adds a group into a Group Policy Object

    .DESCRIPTION
        Use this function to add a group into a Group Policy Object. First you have to create a new group definition object using New-GPPGroup.
        This function is useful if you want to add the same group definition into several Group Policy objects. If you just want to create a single group and add it into a GPO immediately, you can just use the -GPOName/GPOId parameter at New-GPPGroup.

    .PARAMETER InputObject
        Specifies an object of a group definition which you want to add into a GPO.
        You can create one with New-GPPGroup.

        This parameter is mandatory and can be specified by either name or ID.

    .PARAMETER GPOName
        Specifies a Group Policy object name into which you want to add a group.

        This parameter is mandatory when specifying the GPP group item by name.

    .PARAMETER GPOId
        Specifies a Group Policy object ID into which you want to add a group.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

        This parameter is mandatory when specifying the GPP group item by ID.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain where the GPO resides.
        This parameter is optional. If not specified, the function will use the current domain of the current user/computer.

    .EXAMPLE
        PS C:\> Add-GPPGroup -InputObject $group -GPOName "TestGPO"

        This example creates a new GPP group item from $group and adds it to a GPO named "TestGPO".

        $group can be defined like this:
        $group = New-GPPItemGroup -Name "TestGroup"
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [GPPItemGroup]
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

    Add-GPPGroupsItem @PSBoundParameters
}