function Remove-GPPUser {
    <#
    .SYNOPSIS
        Removes a user definition from a GPO object.

    .DESCRIPTION
        The Remove-GPPUser function uses the parameters provided to identify and remove a user from a GPP.
        It supports removal by GPO Name, GPO Id, GPP Section, or a combination of these.

    .PARAMETER Name
        Specifies the name of a user you want to remove from a GPO.

    .PARAMETER LiteralName
        Specifies the name of a user you want to remove from a GPO.
        Does NOT support wildcards.

    .PARAMETER BuiltInUser
        The built-in user to be removed.

    .PARAMETER UID
        Specifies the UID of a user definition you want to remove from a GPO.
        A UID is a unique identifier of an object in GPP.
        You can have several users with the same Name defined in the same
        Group Policy object - those user definitions will have different UIDs.
        You may get a UID of a user by looking at its "uid" property.

    .PARAMETER GPPSection
        You can use this parameter to easily remove user definition
        objects from a GPPSection object which you already have in memory,
        but that parameter is here mostly for intra-module calls.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for users.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for users.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The domain name where the GPO is located.

    .EXAMPLE
        PS C:> Remove-GPPUser -Name "JohnDoe" -GPOName "Default Domain Policy" -DomainName "contoso.com"

        This example removes the user "JohnDoe" from the "Default Domain Policy" GPO in the "contoso.com" domain.

    .EXAMPLE
        PS C:> Remove-GPPUser -UID "12345678-90ab-cdef-1234-567890abcdef" -GPOId "abcdef01-2345-6789-abcd-ef0123456789"

        This example removes the user with the UID "12345678-90ab-cdef-1234-567890abcdef" from the GPO with the ID "abcdef01-2345-6789-abcd-ef0123456789".

    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [string]
        $LiteralName,

        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [GPPItemUserSubAuthority]
        $BuiltInUser,

        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [guid]
        $UID,

        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [GPPSection]
        $GPPSection,

        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [string]
        $DomainName
    )

    $paramRemoveGPPGroupsItem = $PSBoundParameters
    $paramRemoveGPPGroupsItem.Add('ItemType', ([GPPItemUser]))
    if (-not $GPPSection) {
        $paramRemoveGPPGroupsItem.Add('Context', $Context)
    }

    Remove-GPPGroupsItem @paramRemoveGPPGroupsItem
}