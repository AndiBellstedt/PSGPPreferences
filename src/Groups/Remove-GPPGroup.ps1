function Remove-GPPGroup {
    <#
    .SYNOPSIS
        Removes a group definition from a GPO object.

    .DESCRIPTION
        The Remove-GPPGroup function is used to remove a GPP group.
        It has multiple parameter sets to handle different scenarios like
        removing a group by its name, literal name, Security Identifier (SID),
        or unique identifier (UID).

    .PARAMETER Name
        Specifies the name of a group you want to remove from a GPO.

    .PARAMETER LiteralName
        Specifies the name of a group you want to remove from a GPO. Does NOT support wildcards.

    .PARAMETER SID
        Specifies the SID of a group you want to remove from a GPO.

    .PARAMETER UID
        Specifies the UID of a group definition you want to remove from a GPO.
        A UID is a unique identifier of an object in GPP.
        You can have several groups with the same Name/SID combination in the
        same Group Policy object - those group definitions will have different UIDs.
        You may get a UID of a group by looking at its "uid" property.

    .PARAMETER GPPSection
        You can use this parameter to easily remove group definition objects
        from a GPPSection object which you already have in memory,
        but that parameter is here mostly for intra-module calls.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for groups.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for users.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The domain name where the group resides.


    .EXAMPLE
        PS C:> Remove-GPPGroup -Name "TestGroup"

        This example removes the group named "TestGroup".

    .EXAMPLE
        PS C:> Remove-GPPGroup -SID "S-1-5-21-2571216883-1601522099-2002488368-500"

        This example removes the group with the SID "S-1-5-21-2571216883-1601522099-2002488368-500".

    .EXAMPLE
        PS C:> Remove-GPPGroup -UID "3F2504E0-4F89-11D3-9A0C-0305E82C3301"

        This example removes the group with the UID "3F2504E0-4F89-11D3-9A0C-0305E82C3301".

    .EXAMPLE
        PS C:> Remove-GPPGroup -GPOName "TestGPO" -Name "TestGroup"

        This example removes the group named "TestGroup" from the GPO named "TestGPO".
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

        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [guid]
        $UID,

        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [GPPSection]
        $GPPSection,

        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [string]
        $DomainName
    )

    $paramRemoveGPPGroupsItem = $PSBoundParameters
    $paramRemoveGPPGroupsItem.Add('ItemType', ([GPPItemGroup]))
    if (-not $GPPSection) {
        $paramRemoveGPPGroupsItem.Add('Context', $Context)
    }

    Remove-GPPGroupsItem @paramRemoveGPPGroupsItem
}