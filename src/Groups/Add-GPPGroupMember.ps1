function Add-GPPGroupMember {
    <#
    .SYNOPSIS
        Adds a member into a group already existing in a GPO object.

    .DESCRIPTION
        Adds a member into a group already existing in a GPO object.
        Use New-GPPGroupMember to create group members

    .PARAMETER InputObject
        Specifies a member object to add.
        Use New-GPPGroupMember to create one.

        This parameter is mandatory and can be specified by either name, SID, or UID.

    .PARAMETER GroupName
        Specifies the name of a target group.

        This parameter is mandatory when specifying the GPP group member by name.

    .PARAMETER GroupSID
        Specifies the SID of a target group.

        This parameter is mandatory when specifying the GPP group member by SID.

    .PARAMETER GroupUID
        Specifies the UID of a target group. UID is a unique identifier of an object in GPP.
        You can have several groups with the same Name/SID combination in the same
        Group Policy object - those groups will have different UIDs. You may get a UID of
        a group by looking at its "uid" property.

        This parameter is mandatory when specifying the GPP group member by UID.

    .PARAMETER GPOName
        Specifies the name of a GPO where the target group is.

        This parameter is mandatory when specifying the GPP group member by name or SID or UID.

    .PARAMETER GPOId
        Specifies the ID of a GPO where the target group is.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain

        This parameter is mandatory when specifying the GPP group member by name or SID or UID.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain where the GPO resides. This parameter is optional.

    .EXAMPLE
        PS C:\> $member = New-GPPItemGroupMember -Name "TestMember"
        PS C:\> Add-GPPGroupMember -InputObject $member -GroupName "TestGroup" -GPOName "TestGPO"

        This example creates a new GPP group member named "TestMember" and adds it to a group named "TestGroup" in a GPO named "TestGPO".
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory = $true)]
        [GPPItemGroupMember]
        $InputObject,

        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory = $true)]
        [string]
        $GroupName,

        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $GroupSID,

        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory = $true)]
        [guid]
        $GroupUID,

        [Parameter(ParameterSetName = 'ByGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupUID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupUID', Mandatory = $true)]
        [guid]
        $GPOId,

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

    $groupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName

    if ($groupsSection) {
        $paramGetGPPGroup = @{
            GPPSection = $groupsSection
        }
        if ($GroupUID) {
            $paramGetGPPGroup.Add('UID', $GroupUID)
        } elseif ($GroupSID) {
            $paramGetGPPGroup.Add('SID', $GroupSID)
        } else {
            $paramGetGPPGroup.Add('LiteralName', $GroupName)
        }
        if ($DomainName) { $paramGetGPPGroup.Add('DomainName', $DomainName) }

        $filteredGroups = Get-GPPGroup @paramGetGPPGroup

        if ($filteredGroups) {
            foreach ($filteredGroup in $filteredGroups) {
                if ($filteredGroup.Properties.Members) {
                    $filteredGroup.Properties.Members.Add($InputObject)
                } else {
                    $filteredGroup.Properties.Members = $InputObject
                }
            }
        }
    }

    if ($DomainName) {
        Set-GPPSection -InputObject $groupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
    } else {
        Set-GPPSection -InputObject $groupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }
}