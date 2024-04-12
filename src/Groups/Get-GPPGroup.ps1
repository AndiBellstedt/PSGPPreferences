function Get-GPPGroup {
    <#
    .SYNOPSIS
        Retrieves a group from a given Group Policy Preferences instance.

    .DESCRIPTION
        Retrieves a group from a given Group Policy Preferences instance.
        You can get that GPP object either from a GPO or you can pass one
        to the -GPPSection parameter
        (but that's mostly for module's internal stuff).

    .PARAMETER Name
        Specifies the name of a group you want to retrieve.
        Supports wildcards.

    .PARAMETER LiteralName
        Name of a group you want to retrieve.
        Does NOT support wildcards.

    .PARAMETER SID
        Specifies the SID of a group you want to retrieve.

    .PARAMETER UID
        Specifies the UID of a group definition you want to retrieve.
        A UID is a unique identifier of an object in GPP.
        You can have several groups with the same Name/SID combination
        in the same Group Policy object - those group definitions will have different UIDs.
        You may get a UID of a group by looking at its "uid" property.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for groups.

    .PARAMETER GPOId
        Specifies a Group Policy object ID into which you want to add a group.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER GPPSection
        You can use this parameter to easily extract group definition objects
        from a GPPSection object which you already have in memory,
        but that parameter is here mostly for intra-module calls.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain in which to search for the GPP Group item.

    .EXAMPLE
        PS C:> Get-GPPGroup -Name "GroupName"

        This command retrieves the GPP Group item with the name "GroupName".

    .EXAMPLE
        PS C:> Get-GPPGroup -LiteralName "LiteralGroupName"

        This command retrieves the GPP Group item with the literal name "LiteralGroupName".

    .EXAMPLE
        PS C:> Get-GPPGroup -SID "S-1-5-21-3623811015-3361044348-30300820-1013"

        This command retrieves the GPP Group item with the SID "S-1-5-21-3623811015-3361044348-30300820-1013".

    .EXAMPLE
        PS C:> Get-GPPGroup -UID "3F2504E0-4F89-11D3-9A0C-0305E82C3301"

        This command retrieves the GPP Group item with the UID "3F2504E0-4F89-11D3-9A0C-0305E82C3301".

    .EXAMPLE
        PS C:> Get-GPPGroup -GPOName "Default Domain Policy"

        This command retrieves the GPP Group items from the GPO named "Default Domain Policy".

    .EXAMPLE
        PS C:> Get-GPPGroup -GPOId "31B2F340-016D-11D2-945F-00C04FB984F9"

        This command retrieves the GPP Group items from the GPO with the ID "31B2F340-016D-11D2-945F-00C04FB984F9".

    .EXAMPLE
        PS C:> Get-GPPGroup -GPPSection $section

        This command retrieves the GPP Group items from the specified GPP Section.

    .EXAMPLE
        PS C:> Get-GPPGroup -Context "User"

        This command retrieves the GPP Group items using the "User" context.

    .EXAMPLE
        PS C:> Get-GPPGroup -DomainName "contoso.com"

        This command retrieves the GPP Group items from the domain "contoso.com".
    #>
    [CmdletBinding()]
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName')]
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

        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [GPPSection]
        $GPPSection,

        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [string]
        $DomainName
    )

    if (-not $GPPSection) {
        if (-not $GPOId) {
            if ($DomainName) {
                $GPOId = Convert-GPONameToID -Name $GPOName -DomainName $DomainName
            } else {
                $GPOId = Convert-GPONameToID -Name $GPOName
            }
        }

        if ($DomainName) {
            $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
        } else {
            $GPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
        }
    }

    $groups = $GPPSection.Members | Where-Object -FilterScript { $_ -is [GPPItemGroup] }

    if ($groups) {
        if ($UID) {
            $filterScript = { $_.uid -eq $UID }
        } elseif ($SID) {
            $filterScript = { $_.Properties.groupSid -eq $SID }
        } else {
            if ($LiteralName) {
                $filterScript = { $_.Properties.groupName -eq $LiteralName }
            } else {
                $filterName = if ($Name) {
                    $Name
                } else {
                    '*'
                }

                $filterScript = { $_.Properties.groupName -like $filterName }
            }
        }

        $groups | Where-Object -FilterScript $filterScript
    }
}