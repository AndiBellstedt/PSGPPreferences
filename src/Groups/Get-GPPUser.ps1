function Get-GPPUser {
    <#
    .SYNOPSIS
        Retrieves a user from a given Group Policy Preferences instance.

    .DESCRIPTION
        Retrieves a user from a given Group Policy Preferences instance.
        You can get that GPP object either from a GPO or you can pass one
        to the -GPPSection parameter
        (but that's mostly for module's internal stuff).

    .PARAMETER Name
        Specifies the name of a group you want to retrieve.
        Supports wildcards.

    .PARAMETER LiteralName
        Name of a user you want to retrieve.
        Does NOT support wildcards.

    .PARAMETER BuiltInUser
        Allows you to search for user definitions of a system built-in user,
        instead of a regular account.

    .PARAMETER UID
        Specifies the UID of a user definition you want to retrieve.
        A UID is a unique identifier of an object in GPP. You can have
        several users with the same Name defined in the same Group
        Policy object - those user definitions will have different UIDs.
        You may get a UID of a user by looking at its "uid" property.

    .PARAMETER GPOName
        Specifies the name of a GPO in which you want to search for users.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for users.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER GPPSection
        You can use this parameter to easily extract user definition
        objects from a GPPSection object which you already have in memory,
        but that parameter is here mostly for intra-module calls.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER DomainName
        The name of the domain in which the GPO or GPP Section resides.

    .EXAMPLE
        PS C:> Get-GPPUser -GPOName "Default Domain Policy" -Name "Administrator"

        This command retrieves the GPP User item named "Administrator" from the GPO named "Default Domain Policy".

    .EXAMPLE
        PS C:> Get-GPPUser -GPOId "31B2F340-016D-11D2-945F-00C04FB984F9" -UID "4C3DB6BB-4C94-4AC9-8F6A-8B8DE8B84B9F"

        This command retrieves the GPP User item with the UID "4C3DB6BB-4C94-4AC9-8F6A-8B8DE8B84B9F" from the GPO with the UID "31B2F340-016D-11D2-945F-00C04FB984F9".

    .EXAMPLE
        PS C:> Get-GPPUser -GPPSection $section -BuiltInUser "Administrators"

        This command retrieves the GPP User item for the built-in user "Administrators" from the specified GPP Section.

    #>
    [CmdletBinding()]
    [OutputType('GPPItemUser')]
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

        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [GPPItemUserSubAuthorityDisplay]
        $BuiltInUser,

        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [guid]
        $UID,

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

        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [GPPSection]
        $GPPSection,

        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
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

    $users = $GPPSection.Members | Where-Object -FilterScript { $_ -is [GPPItemUser] }
    if ($users) {
        if ($UID) {
            $filterScript = { $_.uid -eq $UID }
        } elseif ($PSBoundParameters.ContainsKey('BuiltInUser')) {
            $builtInUserInternal = [GPPItemUserSubAuthority]$BuiltInUser.value__
            $filterScript = { $_.Properties.subAuthority -eq $builtInUserInternal }
        } else {
            if ($LiteralName) {
                $filterScript = { $_.Properties.userName -eq $LiteralName }
            } else {
                $filterName = if ($Name) {
                    $Name
                } else {
                    '*'
                }

                $filterScript = { $_.Properties.userName -like $filterName }
            }
        }

        $users | Where-Object -FilterScript $FilterScript
    }
}