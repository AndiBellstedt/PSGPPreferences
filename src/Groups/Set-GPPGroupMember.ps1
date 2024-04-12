function Set-GPPGroupMember {
    <#
    .SYNOPSIS
        Sets properties of a group member defined in a Group Policy object.

    .DESCRIPTION
        Sets properties of a group member defined in a Group Policy object.
        Well, actually the only property you can change is
        "Action" - there's just not much to set.

    .PARAMETER Name
        Specifies the name of a member which you want to change.

    .PARAMETER SID
        Specifies the SID of a member which you want to change.

    .PARAMETER Action
        Specifies which action should GPP engine to execute regarding this security principal: either to ADD or to REMOVE it from a group.

    .PARAMETER GroupName
        Specifies the name of a group in which you want to change a member.

    .PARAMETER GroupSID
        Specifies the SID of a group in which you want to change a member.

    .PARAMETER GroupUID
        Specifies the UID of a group in which you want to change a member.
        A UID is a unique identifier of an object in GPP.
        You can have several groups with the same Name/SID combination in
        the same Group Policy object - those groups will have different UIDs.
        You may get a UID of a group by looking at its "uid" property.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for groups.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for groups. It is a name of a Group Policy's object in Active Directory. Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER DomainName
        Specifies the domain name of the domain where the group policy is located.
        If not specified, the domain name will be determined automatically.
    .EXAMPLE
        PS C:> Set-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action ADD -GroupName 'Administrators (built-in)' -GPOName 'Custom Group Policy'

        Sets the action to ADD for the "EXAMPLE\Administrator" user in the "Administrators (built-in)" group in a group policy named "Custom Group Policy".

    .EXAMPLE
        PS C:> Set-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action REMOVE -GroupSID 'S-1-5-32-544' -GPOName 'Custom Group Policy'

        Sets the action to REMOVE for the "EXAMPLE\Administrator" user in a group with the SID S-1-5-32-544 a group policy named "Custom Group Policy".
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

        [Parameter(Mandatory = $true)]
        [GPPItemGroupMemberAction]
        $Action,

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

        if ($DomainName) {
            $paramGetGPPGroup.Add('DomainName', $DomainName)
        }

        $filteredGroups = Get-GPPGroup @paramGetGPPGroup

        if ($filteredGroups) {
            $workDone = $false
            foreach ($filteredGroup in $filteredGroups) {
                if ($filteredGroup.Properties.Members) {
                    if ($SID) {
                        $FilterScript = { $_.sid -eq $SID }
                    } else {
                        $FilterScript = { $_.name -eq $Name }
                    }

                    $filteredMembers = $filteredGroup.Properties.Members | Where-Object -FilterScript $FilterScript
                    if ($filteredMembers) {
                        $workDone = $true
                        foreach ($filteredMember in $filteredMembers) {
                            $filteredMember.action = $Action
                        }
                    }
                }
            }

            if ($workDone) {
                if ($DomainName) {
                    Set-GPPSection -InputObject $groupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
                } else {
                    Set-GPPSection -InputObject $groupsSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
                }
            }
        }
    }
}
