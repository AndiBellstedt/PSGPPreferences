function Add-GPPUser {
    <#
    .SYNOPSIS
        Adds a user item into a Group Policy Object

    .DESCRIPTION
        Use this function to add a user into a Group Policy Object.
        First you have to create a new user definition object using New-GPPUser.
        This function is useful if you want to add the same user definition into
        several Group Policy objects. If you just want to create a single user and
        add it into a GPO immediately, you can just use the -GPOName/GPOId parameter
        of New-GPPGroup.

    .PARAMETER InputObject
        Specifies an object of a user definition which you want to add into a GPO.
        You can create one with New-GPPUser.

    .PARAMETER GPOName
        The name of the GPO where the GPP user will be added.

        This parameter is mandatory when specifying the GPP user by name.

    .PARAMETER GPOId
        The ID of the GPO where the GPP user will be added.

        This parameter is mandatory when specifying the GPP user by ID.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain where the GPO resides. This parameter is optional.

    .EXAMPLE
        PS C:\> Add-GPPUser -InputObject $UserObject -GPOName 'TEST'

        Adds a user definition object $Userbject into a Group Policy named TEST.
        $UserObject is created with New-GPPUser:
        PS C:\> $UserObject = New-GPPItemUser -Name "TestUser"

    .EXAMPLE
        PS C:\> Add-GPPUser -InputObject $UserObject -GPOId '31B2F340-016D-11D2-945F-00C04FB984F9

        Adds a user definition object $UserObject into a Group Policy by using its ID (see the description for the -GPOId parameter below).
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [GPPItemUser]
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