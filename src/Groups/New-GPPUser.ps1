function New-GPPUser {
    <#
    .SYNOPSIS
        Creates a new Group Policy Preferences user definition.


    .DESCRIPTION
        Creates a new Group Policy Preferences user definition.
        You can either save it in the memory for additional
        processing or immediately put into a GPO by using the -GPOName or -GPOId parameters.

        Note that available parameters depend on the
        action you choose: -Update or -Delete.

        This mimics the GUI behavior.

    .PARAMETER Name
        Specifies the name of a user.

    .PARAMETER BuiltInUser
        Allows you to target your user definition to a system built-in user,
        instead of a regular account.

    .PARAMETER Update
        Switch to indicate if the user should be updated.

    .PARAMETER Delete
        Sets the action property of the user definition to "Delete".

    .PARAMETER GPOName
        Specifies the name of a GPO into which you want to add the newly created user definition.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for users.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER GPPSection
        You can use this parameter to easily extract user definition objects from a GPPSection object which you already have in memory, but that parameter is here mostly for intra-module calls.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER NewName
        Specifies the new name of a user if you want to rename it on target hosts.

    .PARAMETER FullName
        Specifies a full name for the target account.

    .PARAMETER Description
        Sets the description of a user object.

    .PARAMETER AccountDisabled
        Specifies that the target user account must be disabled.

    .PARAMETER UserMayNotChangePassword
        Specifies that the target account should not be able to change its password by itself.

    .PARAMETER UserMustChangePassword
        Specifies that the target account must change its password at the next logon.

    .PARAMETER Disable
        Disables processing of this group object.
        In the GUI you'll see it greyed out.

    .PARAMETER AccountExpires
        Specifies that this user account should expire at a given date in the future.
        Despite that you pass a full DateTime object to this parameter, only date will be used.

    .PARAMETER PasswordNeverExpires
        Speficies that the password of the target account should not expire.

    .PARAMETER DomainName
        Specifies the domain name to use when adding the user to a GPO.

    .PARAMETER PassThru
        Returns a new user definition object to the pipeline.

    .EXAMPLE
        PS C:> New-GPPUser -Name "JohnDoe" -Update

        This example updates the user "JohnDoe".

    .EXAMPLE
        PS C:> New-GPPUser -Name "JohnDoe" -Delete

        This example deletes the user "JohnDoe".

    .EXAMPLE
        PS C:> New-GPPUser -Name "JohnDoe" -Update -NewName "JaneDoe"

        This example updates the user "JohnDoe" and changes their name to "JaneDoe".

    .EXAMPLE
        PS C:> New-GPPUser -Name "JohnDoe" -Update -AccountDisabled $true

        This example updates the user "JohnDoe" and disables their account.

    .EXAMPLE
        PS C:> New-GPPUser -Name "JohnDoe" -Update -AccountExpires (Get-Date).AddDays(30)

        This example updates the user "JohnDoe" and sets their account to expire in 30 days.

    #>
    [CmdletBinding()]
    [OutputType('GPPItemUser', ParameterSetName = ('ByObjectNameUpdate', 'BuiltInUserUpdate', 'ByObjectNameDelete', 'ByObjectNameUpdateUserMustChangePassword', 'BuiltInUserUpdateUserMustChangePassword'))]
    Param (
        [Parameter(ParameterSetName = 'ByObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'BuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [GPPItemUserSubAuthorityDisplay]
        $BuiltInUser,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [switch]
        $Update,

        [Parameter(ParameterSetName = 'ByObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory = $true)]
        [switch]
        $Delete,

        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]
        $NewName,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]
        $FullName,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [switch]
        $AccountDisabled,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [datetime]
        $AccountExpires,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [switch]
        $PasswordNeverExpires,

        [Parameter(ParameterSetName = 'ByObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'BuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [switch]
        $UserMayNotChangePassword,

        [Parameter(ParameterSetName = 'ByObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'BuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword', Mandatory = $true)]
        [switch]
        $UserMustChangePassword,

        [switch]
        $Disable,

        [string]
        $DomainName,

        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectNameUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUserUpdateUserMustChangePassword')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUserUpdateUserMustChangePassword')]
        [switch]
        $PassThru
    )

    $Action = if ($Update) {
        [GPPItemAction]::U
    } else {
        [GPPItemAction]::D
    }

    if ($PSBoundParameters.ContainsKey('BuiltInUser')) {
        $builtInUserInternal = [GPPItemUserSubAuthority]$BuiltInUser.value__

        if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
            $properties = [GPPItemPropertiesUser]::new($Action, $builtInUserInternal, $NewName, $FullName, $Description, $UserMustChangePassword, $AccountDisabled, $AccountExpires)
        } else {
            $properties = [GPPItemPropertiesUser]::new($Action, $builtInUserInternal, $NewName, $FullName, $Description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $AccountExpires)
        }
    } else {
        if ($PSBoundParameters.ContainsKey('UserMustChangePassword')) {
            $properties = [GPPItemPropertiesUser]::new($Action, $Name, $NewName, $FullName, $Description, $UserMustChangePassword, $AccountDisabled, $AccountExpires)
        } else {
            $properties = [GPPItemPropertiesUser]::new($Action, $Name, $NewName, $FullName, $Description, $UserMayNotChangePassword, $PasswordNeverExpires, $AccountDisabled, $AccountExpires)
        }
    }

    $user = [GPPItemUser]::new($properties, $Disable)

    if ($GPOName -or $GPOId) {
        $paramAddGPPUser = @{
            InputObject = $user
            Context     = $Context
        }

        if ($GPOId) {
            $paramAddGPPUser.Add('GPOId', $GPOId)
        } else {
            $paramAddGPPUser.Add('GPOName', $GPOName)
        }

        if ($DomainName) {
            $paramAddGPPUser.Add('DomainName', $DomainName)
        }

        if ($PassThru) {
            $user
        }
        Add-GPPUser @paramAddGPPUser
    } else {
        $user
    }
}