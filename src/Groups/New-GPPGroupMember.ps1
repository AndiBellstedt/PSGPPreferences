function New-GPPGroupMember {
    <#
    .SYNOPSIS
        Creates a new group member object to use in other commands later.

    .DESCRIPTION
        Creates a new group member object in memory.
        Use the created object in Add-GPPGroupMember, New-GPPGroup, or Set-GPPGroup.
        The result object MUST have both the name and SID filled,
        so the function resolves one through another and fails if it does not succeed.

    .PARAMETER Name
        Specifies the name of a security principal.

        This is a mandatory parameter.

    .PARAMETER SID
        The Security Identifier (SID) of the group member.

        This is a mandatory parameter.

    .PARAMETER Action
        Specifies which action should GPP engine to execute regarding
        this security principal: either to ADD or to REMOVE it from a group.

    .EXAMPLE
        PS C:> New-GPPGroupMember -Name "EXAMPLE\Administrator" -Action ADD

        Uses the -Name parameter to resolve the SID of this security principal from Active Directory domain. The result object will have its action set to "ADD".

    .EXAMPLE
        PS C:> New-GPPGroupMember -SID "S-1-5-21-2571216883-1601522099-2002488368-500" -Action REMOVE

        This command removes the GPP group member with the SID "S-1-5-21-2571216883-1601522099-2002488368-500" from the group.

    #>
    [CmdletBinding()]
    [OutputType('GPPItemGroupMember')]
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'BySID', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'BySID')]
        [GPPItemGroupMemberAction]
        $Action
    )

    if ($Name) {
        try {
            $SID = ([System.Security.Principal.NTAccount]::new($Name)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        } catch {
            # https://github.com/exchange12rocks/PSGPPreferences/issues/31
            # Not all names should be resolved into SIDs. Especially names with GPP variables in them.

            $SID = $null
            if ($_.FullyQualifiedErrorId -ne 'IdentityNotMappedException') {
                throw $_
            }
        }
    } else {
        $Name = [System.Security.Principal.SecurityIdentifier]::new($SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    [GPPItemGroupMember]::new($Action, $Name, $SID)
}