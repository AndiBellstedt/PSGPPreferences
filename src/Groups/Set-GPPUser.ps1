function Set-GPPUser {
    <#
    .SYNOPSIS
        Sets properties of a user definition in a specified Group Policy object.

    .DESCRIPTION
        Sets properties of a user definition in a specified Group Policy object.
        You may also use it to write a user definition object from memory into
        a GPO and changing some of its properties in the process.

        If you want just to add a user definition into a GPO, w/o any modifications,
        I suggest you to use Add-GPPUser.

    .PARAMETER InputObject
        Specifies the user definition object you want to change.
        You may use Get-GPPUser to get such an object.

    .PARAMETER Name
        Specifies the name of a user which you want to change.
        Supports wildcards.

    .PARAMETER LiteralName
        Specifies the name of a user which you want to change.
        Does not support wildcards.

    .PARAMETER BuiltInUser
        Allows you to target your user definition to a system built-in user, instead of a regular account.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for user definitions.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for user definitions.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER InputObject
        If you already have a user definition object in memory,
        which you want to write into a Group Policy,
        you can pass in into this parameter.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER Action
        Sets one of two actions which you can instruct the GPP engine to do with a user: Update or Delete. Different actions have different sets of allowed parameters.
        The function initially does not restrict you from pass parameters incompatible with Action, but will correct them to be in accordance with the action. i.e. if you set -Action to "Delete" and -NewName to something, -NewName will be ignored.
        Also, if you have a user object with some properties defined and change its action to "Delete", the object will be stripped off its properties.

        For properties compatibility see help for New-GPPUser.

    .PARAMETER NewName
        Specifies a new name for a user if you want to rename it on target hosts.

    .PARAMETER FullName
        Specifies the full name of a user definition.

    .PARAMETER Description
        Specifies the description of a user definition.

    .PARAMETER AccountDisabled
        Specifies that the target user account must be disabled.

    .PARAMETER AccountExpires
        Specifies that this user account should expire at a given date in the future.
        Despite that you pass a full DateTime object to this parameter, only date will be used.

    .PARAMETER PasswordNeverExpires
        Specifies whether the password of a user definition never expires.

    .PARAMETER UserMayNotChangePassword
        Specifies whether a user definition may not change its password.

    .PARAMETER UserMustChangePassword
        Specifies whether a user definition must change its password.

    .PARAMETER Disable
        Disables processing of this group definition. In the GUI you'll see it greyed out.

    .PARAMETER DomainName
        Specifies the domain name of the domain where the group policy is located.
        If not specified, the domain name will be determined automatically.

    .PARAMETER PassThru
        Returns the object that was changed. By default, this cmdlet does not generate any output.

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action DELETE -GPOName 'Custom Group Policy'

        Sets the action to DELETE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy".

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -NewName 'EXAMPLE\Administrator2'

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and changes its name to "EXAMPLE\Administrator2".

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -FullName 'Administrator of EXAMPLE domain'

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and changes its full name to "Administrator of EXAMPLE domain".

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -Description 'Administrator of EXAMPLE domain'

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and changes its description to "Administrator of EXAMPLE domain".

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -AccountDisabled $true

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and disables its account.

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -AccountExpires (Get-Date).AddDays(1)

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and sets the account expiration date to tomorrow.

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -PasswordNeverExpires $true

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and sets the password expiration to never.

    .EXAMPLE
        PS C:> Set-GPPUser -Name 'EXAMPLE\Administrator' -Action UPDATE -GPOName 'Custom Group Policy' -UserMayNotChangePassword $true

        Sets the action to UPDATE for the "EXAMPLE\Administrator" user in a group policy named "Custom Group Policy" and sets the user to not be able to change its password.

    #>
    [CmdletBinding()]
    [OutputType('GPPItemUser')]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory = $true)]
        [GPPItemUser[]]
        $InputObject,

        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [string]
        $LiteralName,

        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [GPPItemUserSubAuthorityDisplay]
        $BuiltInUser,

        [Parameter(ParameterSetName = 'ByGPONameObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObject', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [guid]
        $GPOId,


        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,


        [GPPItemUserActionDisplay]
        $Action,


        [string]
        $NewName,


        [string]
        $FullName,


        [string]
        $Description,


        [bool]
        $AccountDisabled,


        [datetime]
        $AccountExpires,

        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]
        $PasswordNeverExpires,

        [Parameter(ParameterSetName = 'ByGPONameObject')]
        [Parameter(ParameterSetName = 'ByGPOIdObject')]
        [Parameter(ParameterSetName = 'ByGPONameItemName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemName')]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUser')]
        [bool]
        $UserMayNotChangePassword,

        [Parameter(ParameterSetName = 'ByGPONameObjectUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemLiteralNameUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdItemBuiltInUserUserMustChangePassword', Mandatory = $true)]
        [bool]
        $UserMustChangePassword,


        [bool]
        $Disable,

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

            if ($BuiltInUser) {
                $paramGetFunction.Add('BuiltInUser', $BuiltInUser)
            } elseif ($LiteralName) {
                $paramGetFunction.Add('LiteralName', $LiteralName)
            } else {
                $paramGetFunction.Add('Name', $Name)
            }

            if ($DomainName) {
                $paramGetFunction.Add('DomainName', $DomainName)
            }

            $InputObject = Get-GPPUser @paramGetFunction
        }

        if ($InputObject) {
            foreach ($userObject in $InputObject) {
                if ($PSBoundParameters.ContainsKey('Action')) {
                    $userObject.Properties.Action = switch ($Action) {
                        ([GPPItemUserActionDisplay]::Update) {
                            [GPPItemAction]::U
                        }
                        ([GPPItemUserActionDisplay]::Delete) {
                            [GPPItemAction]::D
                        }
                    }
                }

                if ($userObject.Properties.Action -ne [GPPItemAction]::D) {
                    if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
                        if ($UserMustChangePassword) {
                            $userObject.Properties.noChange = $null
                            $userObject.Properties.neverExpires = $null
                        }
                        $userObject.Properties.changeLogon = $UserMustChangePassword
                    } elseif ($PSBoundParameters.ContainsKey('PasswordNeverExpires') -or $PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                        if ($PasswordNeverExpires -or $UserMayNotChangePassword) {
                            $userObject.Properties.changeLogon = $null
                        }
                        if ($PSBoundParameters.ContainsKey('PasswordNeverExpires')) {
                            $userObject.Properties.neverExpires = $PasswordNeverExpires
                        }
                        if ($PSBoundParameters.ContainsKey('UserMayNotChangePassword')) {
                            $userObject.Properties.noChange = $UserMayNotChangePassword
                        }
                    }

                    if ($PSBoundParameters.ContainsKey('NewName')) {
                        $userObject.Properties.newName = $NewName
                    }
                    if ($PSBoundParameters.ContainsKey('FullName')) {
                        $userObject.Properties.fullName = $FullName
                    }
                    if ($PSBoundParameters.ContainsKey('Description')) {
                        $userObject.Properties.description = $Description
                    }
                    if ($PSBoundParameters.ContainsKey('AccountDisabled')) {
                        $userObject.Properties.acctDisabled = $AccountDisabled
                    }
                    if ($PSBoundParameters.ContainsKey('AccountExpires')) {
                        $userObject.Properties.expires = Convert-DateTimeToGPPExpirationDate -DateTime $AccountExpires
                    }
                } else {
                    $userObject.Properties.newName = $null
                    $userObject.Properties.fullName = $null
                    $userObject.Properties.description = $null
                    $userObject.Properties.changeLogon = $null
                    $userObject.Properties.noChange = $null
                    $userObject.Properties.neverExpires = $null
                    $userObject.Properties.acctDisabled = $null
                    $userObject.Properties.subAuthority = $null
                    $userObject.Properties.expires = $null
                }

                if ($PSBoundParameters.ContainsKey('Disable')) {
                    $userObject.disabled = $Disable
                }

                $userObject.image = $userObject.Properties.action.value__ # Fixes up the item's icon in case we changed its action

                if ($DomainName) {
                    $newGPPSection = Remove-GPPUser -GPPSection $gppSection -UID $userObject.uid -DomainName $DomainName
                } else {
                    $newGPPSection = Remove-GPPUser -GPPSection $gppSection -UID $userObject.uid
                }

                if ($newGPPSection) {
                    $newGPPSection.Members.Add($userObject)
                } else {
                    $newGPPSection = [GPPSectionGroups]::new($userObject, $false)
                }

                if ($PassThru) {
                    $userObject
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