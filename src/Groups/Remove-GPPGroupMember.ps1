function Remove-GPPGroupMember {
    <#
    .SYNOPSIS
        Removes a member from a group defined in a Group Policy object.

    .DESCRIPTION
        Removes a member from a group defined in a Group Policy object.
        This doesn't necessary remove that member from computers to which
        the GPO applies - it depends on the group's and member's configuration.

    .PARAMETER Name
        Specifies the name of a member which you want to remove.

    .PARAMETER SID
        Specifies the SID of a member which you want to remove.

    .PARAMETER GroupName
        Specifies the name of a group from which you want to remove a member.

    .PARAMETER GroupSID
        Specifies the SID of a group from which you want to remove a member.

    .PARAMETER GroupUID
        Specifies the UID of a group from which you want to remove a member.
        A UID is a unique identifier of an object in GPP.
        You can have several groups with the same Name/SID combination in
        the same Group Policy object - those groups will have different UIDs.
        You may get a UID of a group by looking at its "uid" property.

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
        PS C:> Remove-GPPGroupMember -Name "TestMember" -GroupName "TestGroup"

        This example removes the member named "TestMember" from the group named "TestGroup".

    .EXAMPLE
        PS C:> Remove-GPPGroupMember -SID "S-1-5-21-2571216883-1601522099-2002488368-500" -GroupSID "S-1-5-21-2571216883-1601522099-2002488368-501"

        This example removes the member with the SID "S-1-5-21-2571216883-1601522099-2002488368-500" from the group with the SID "S-1-5-21-2571216883-1601522099-2002488368-501".

    .EXAMPLE
        PS C:> Remove-GPPGroupMember -Name "TestMember" -GroupUID "3F2504E0-4F89-11D3-9A0C-0305E82C3301"

        This example removes the member named "TestMember" from the group with the UID "3F2504E0-4F89-11D3-9A0C-0305E82C3301".

    .EXAMPLE
        PS C:> Remove-GPPGroupMember -Name "TestMember" -GPOName "TestGPO" -GroupName "TestGroup"

        This example removes the member named "TestMember" from the group named "TestGroup" in the GPO named "TestGPO".
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory = $true)]
        [string]
        $GroupName,

        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $GroupSID,

        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory = $true)]
        [guid]
        $GroupUID,

        [Parameter(ParameterSetName = 'ByNameGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPONameGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPONameGroupUID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByNameGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByNameGPOIdGroupUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BySIDGPOIdGroupUID', Mandatory = $true)]
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

    if ($DomainName) {
        $groupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
    } else {
        $groupsSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
    }

    if ($groupsSection) {
        $ParamGetGPPGroup = @{
            GPPSection = $groupsSection
        }

        if ($GroupUID) {
            $ParamGetGPPGroup.Add('UID', $GroupUID)
        } elseif ($GroupSID) {
            $ParamGetGPPGroup.Add('SID', $GroupSID)
        } else {
            $ParamGetGPPGroup.Add('LiteralName', $GroupName)
        }

        if ($DomainName) {
            $ParamGetGPPGroup.Add('DomainName', $DomainName)
        }

        $filteredGroups = Get-GPPGroup @ParamGetGPPGroup

        if ($filteredGroups) {
            $workDone = $false
            foreach ($filteredGroup in $filteredGroups) {
                if ($filteredGroup.Properties.Members) {
                    if ($SID) {
                        $filterScript = { $_.sid -eq $SID }
                    } else {
                        $filterScript = { $_.name -eq $Name }
                    }

                    $filteredMembers = $filteredGroup.Properties.Members | Where-Object -FilterScript $filterScript
                    if ($filteredMembers) {
                        $workDone = $true
                        foreach ($filteredMember in $filteredMembers) {
                            [void]$filteredGroup.Properties.Members.Remove($filteredMember)
                        }
                    }
                }
            }

            if ($workDone) {
                Set-GPPSection -InputObject $groupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
            }
        }
    }
}