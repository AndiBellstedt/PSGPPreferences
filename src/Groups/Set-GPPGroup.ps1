function Set-GPPGroup {
    <#
    .SYNOPSIS
        Sets properties of a group definition in a specified Group Policy object.

    .DESCRIPTION
        Sets properties of a group definition in a specified Group Policy object.
        You may also use it to write a group definition object from memory into
        a GPO and changing some of its properties in the process.

        If you want just to add a group definition into a GPO, w/o any modifications,
        I suggest you to use Add-GPPGroup.

    .PARAMETER InputObject
        If you already have a group definition object in memory,
        which you want to write into a Group Policy,
        you can pass in into this parameter.

    .PARAMETER Name
        The name of the GPP Group to be modified.

    .PARAMETER LiteralName
        Specifies the name of a group which you want to change. Does not support wildcards.

    .PARAMETER SID
        The Security Identifier (SID) of the GPP Group to be modified.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for groups.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for groups.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER Action
        Sets one of four actions which you can instruct the GPP engine to do
        with a group: Create, Replace, Update, or Delete.
        Different actions have different sets of allowed parameters.

        The function initially does not restrict you from pass parameters incompatible with Action, but will correct them to be in accordance with the action. i.e. if you set -Action to "Delete" and -NewName to something, -NewName will be ignored.
        Also, if you have a group object with some properties defined and change its action to "Delete", the object will be stripped off its properties. Same concept applies to other actions as well.

        For properties compatibility see help for New-GPPGroup.

    .PARAMETER Members
        Specifies which group members should be set for this group.
        Use New-GPPGroupMember to create them.

        This parameter is only applicable to the Replace and Update actions.

    .PARAMETER NewName
        Specifies a new name for a group if you want to rename it on target hosts.

        This parameter is only applicable to the Update action.

    .PARAMETER Description
        Sets the description of a group object.

    .PARAMETER DeleteAllUsers
        If set, all users will be removed from the group.
        This parameter is only applicable to the Replace and Update actions.

    .PARAMETER DeleteAllGroups
        If set, all groups will be removed from the group.
        This parameter is only applicable to the Replace and Update actions.

    .PARAMETER Disable
        Disables processing of this group definition. In the GUI you'll see it greyed out.

    .PARAMETER DomainName
        Specifies the name of the domain in which the GPO is located.

        If not specified, the domain of the current user is used.

    .PARAMETER PassThru
        Returns the modified group object.
    .EXAMPLE
        PS C:> Set-GPPGroup -Name "Admins" -GPOName "Default Domain Policy" -Action "Update"

        This example modifies the "Admins" GPP Group in the "Default Domain Policy" GPO, setting its action to "Update".

    .EXAMPLE
        PS C:> Set-GPPGroup -SID "S-1-5-21-3623811015-3361044348-30300820-1013" -GPOId "abcdef01-2345-6789-abcd-ef0123456789" -Action "Delete"

        This example modifies the GPP Group with the SID "S-1-5-21-3623811015-3361044348-30300820-1013" in the GPO with the ID "abcdef01-2345-6789-abcd-ef0123456789", setting its action to "Delete".

    #>
    [CmdletBinding()]
    [OutputType('GPPItemGroup')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory = $true)]
        [GPPItemGroup[]]
        $InputObject,

        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory = $true)]
        [string]
        $LiteralName,

        [Parameter(ParameterSetName = 'ByGPONameItemSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemSID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemSID', Mandatory = $true)]
        [guid]
        $GPOId,

        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [GPPItemActionDisplay]
        $Action,

        [string]
        $NewName,

        [string]
        $Description,

        [switch]
        $DeleteAllUsers,

        [switch]
        $DeleteAllGroups,

        [switch]
        $Disable,

        [GPPItemGroupMember[]]
        $Members,

        [string]
        $DomainName,

        [switch]
        $PassThru
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
        if (-not $InputObject) {
            $paramGetFunction = @{
                GPPSection = $gppSection
            }

            if ($SID) {
                $paramGetFunction.Add('SID', $SID)
            } elseif ($LiteralName) {
                $paramGetFunction.Add('LiteralName', $LiteralName)
            } else {
                $paramGetFunction.Add('Name', $Name)
            }

            if ($DomainName) {
                $paramGetFunction.Add('DomainName', $DomainName)
            }

            $InputObject = Get-GPPGroup @paramGetFunction
        }

        if ($InputObject) {
            foreach ($groupObject in $InputObject) {
                if ($PSBoundParameters.ContainsKey('Action')) {
                    if ($PSBoundParameters.ContainsKey('Action')) {
                        $groupObject.Properties.Action = [GPPItemAction]$Action.value__
                    } else {
                        $groupObject.Properties.Action = [GPPItemAction]::U
                    }
                }

                if ($groupObject.Properties.Action -ne [GPPItemAction]::D) {
                    if ($PSBoundParameters.ContainsKey('NewName')) {
                        if ($groupObject.Properties.Action -eq [GPPItemAction]::U) {
                            $groupObject.Properties.NewName = $NewName
                        }
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                        $groupObject.Properties.Description = $Description
                    }
                    if ($PSBoundParameters.ContainsKey('DeleteAllUsers')) {
                        $groupObject.Properties.DeleteAllUsers = $DeleteAllUsers
                    }
                    if ($PSBoundParameters.ContainsKey('DeleteAllGroups')) {
                        $groupObject.Properties.DeleteAllGroups = $DeleteAllGroups
                    }
                    if ($PSBoundParameters.ContainsKey('Members')) {
                        $groupObject.Properties.Members = $Members
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                    }

                    # The NewName property applicable to the Update action only
                    if ($groupObject.Properties.Action -eq [GPPItemAction]::C -and $groupObject.Properties.NewName) {
                        $groupObject.Properties.NewName = $null
                    }
                } else {
                    # Items with the Delete action, should not have all these properties (GUI sets it this way)
                    $groupObject.Properties.NewName = $null
                    $groupObject.Properties.Description = $null
                    $groupObject.Properties.DeleteAllUsers = $null
                    $groupObject.Properties.DeleteAllGroups = $null
                    $groupObject.Properties.Members = $null
                }

                if ($PSBoundParameters.ContainsKey('Disable')) {
                    $groupObject.disabled = $Disable
                }

                $groupObject.image = $groupObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

                if ($DomainName) {
                    $newGPPSection = Remove-GPPGroup -GPPSection $gppSection -UID $groupObject.uid -DomainName $DomainName
                } else {
                    $newGPPSection = Remove-GPPGroup -GPPSection $gppSection -UID $groupObject.uid -DomainName $DomainName
                }

                if ($newGPPSection) {
                    $newGPPSection.Members.Add($groupObject)
                } else {
                    $newGPPSection = [GPPSectionGroups]::new($groupObject, $false)
                }

                if ($PassThru) {
                    $groupObject
                }

                if ($DomainName) {
                    Set-GPPSection -InputObject $newGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
                } else {
                    Set-GPPSection -InputObject $newGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
                }
            }
        }
    }
}