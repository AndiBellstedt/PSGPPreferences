function Get-GPPGroupMember {
    <#
    .SYNOPSIS
        Retrieves a member from a group defined in a Group Policy objects.

    .DESCRIPTION
        This function retrieves members of a GPP group.
        You can specify the group member to retrieve by name, literal name, or SID.
        You can specify the GPP group by name, SID, or UID. You can specify the Group Policy Object (GPO) by name or ID.
        You can also specify the GPP context and the domain name.

    .PARAMETER Name
        Specifies the name of a member which you want to retrieve.
        Supports wildcards.

    .PARAMETER LiteralName
        Specifies the name of a member which you want to retrieve.
        Does NOT support wildcards.

    .PARAMETER SID
        Specifies the SID of a member which you want to retrieve.

    .PARAMETER GroupName
        Specifies the name of a group from which you want to get a member.

    .PARAMETER GroupSID
        Specifies the SID of a group from which you want to get a member.

    .PARAMETER GroupUID
        Specifies the UID of a group from which you want to get a member.
        A UID is a unique identifier of an object in GPP. You can have
        several groups with the same Name/SID combination in the same
        Group Policy object - those groups will have different UIDs.
        You may get a UID of a group by looking at its "uid" property.

    .PARAMETER GPOName
        Specifies a Group Policy object name into which you want to add a group.

    .PARAMETER GPOId
        Specifies a Group Policy object ID into which you want to add a group.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain.

    .OUTPUTS
        GPPItemGroupMember
        Outputs a GPPItemGroupMember object for each matching group member.

    .EXAMPLE
        PS C:> Get-GPPGroupMember -Name "JohnDoe" -GroupName "Admins" -GPOName "Default Domain Policy"

    .EXAMPLE
        PS C:> Get-GPPGroupMember -SID "S-1-5-21-3623811015-3361044348-30300820-1013" -GroupName "Admins" -GPOName "Default Domain Policy"

    .EXAMPLE
        PS C:> Get-GPPGroupMember -LiteralName "JohnDoe" -GroupName "Admins" -GPOName "Default Domain Policy"
    #>
    [CmdletBinding()]
    [OutputType('GPPItemGroupMember')]
    Param (
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName')]
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId')]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory = $true)]
        [string]
        $LiteralName,

        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory = $true)]
        [string]
        $GroupName,

        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $GroupSID,

        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory = $true)]
        [guid]
        $GroupUID,

        [Parameter(ParameterSetName = 'ByNameGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOName', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByNameGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupNameGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupSIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGroupUIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByLiteralNameGroupUIDGPOId', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGroupUIDGPOId', Mandatory = $true)]
        [guid]
        $GPOId,

        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [string]
        $DomainName
    )

    $paramGetGPPGroup = @{}

    if ($GroupUID) {
        $paramGetGPPGroup.Add('UID', $GroupUID)
    } elseif ($GroupSID) {
        $paramGetGPPGroup.Add('UID', $GroupUID)
    } else {
        $paramGetGPPGroup.Add('LiteralName', $GroupName)
    }

    if ($GPOId) {
        $paramGetGPPGroup.Add('GPOId', $GPOId)
    } else {
        $paramGetGPPGroup.Add('GPOName', $GPOName)
    }

    if ($DomainName) {
        $paramGetGPPGroup.Add('DomainName', $DomainName)
    }

    $groups = Get-GPPGroup @paramGetGPPGroup

    if ($SID) {
        $filterScript = { $_.sid -eq $SID }
    } elseif ($LiteralName) {
        $filterScript = { $_.name -eq $LiteralName }
    } else {
        $filterName = if ($Name) {
            $Name
        } else {
            '*'
        }

        $filterScript = { $_.name -like $filterName }
    }

    foreach ($group in $groups) {
        $group.Properties.Members | Where-Object -FilterScript $filterScript
    }
}