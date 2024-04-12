function Remove-GPPGroupsItem {
    <#
    .SYNOPSIS
        Removes a Group Policy Preferences (GPP) item from a GPP section.

    .DESCRIPTION
        The Remove-GPPGroupsItem function removes a GPP item from a GPP section based on the provided parameters.
        The function supports removal by GPO Name, GPO Id, or directly from a GPP Section.
        The item to remove can be specified by Name, LiteralName, SID, BuiltInUser, or UID.

    .PARAMETER Name
        The name of the GPP item to remove.

    .PARAMETER LiteralName
        The literal name of the GPP item to remove.

    .PARAMETER SID
        The Security Identifier (SID) of the GPP item to remove.

    .PARAMETER BuiltInUser
        The built-in user of the GPP item to remove.

    .PARAMETER UID
        The unique identifier (UID) of the GPP item to remove.

    .PARAMETER GPPSection
        The GPP section from which to remove the GPP item.

    .PARAMETER GPOName
        The name of the Group Policy Object (GPO) from which to remove the GPP item.

    .PARAMETER GPOId
        The unique identifier (Id) of the GPO from which to remove the GPP item.

    .PARAMETER Context
        The context of the GPP item to remove.

    .PARAMETER ItemType
        The type of the GPP item to remove.

    .PARAMETER DomainName
        The domain name of the GPP item to remove.

    .EXAMPLE
        PS C:> Remove-GPPGroupsItem -Name "GroupName" -GPOName "GPOName" -ItemType [GPPItemGroup]

        This command removes a GPP item with the name "GroupName" from the GPO named "GPOName".

    .EXAMPLE
        PS C:> Remove-GPPGroupsItem -LiteralName "LiteralName" -GPOId "GPOId" -ItemType [GPPItemUser]

        This command removes a GPP item with the literal name "LiteralName" from the GPO with the Id "GPOId".

    .EXAMPLE
        PS C:> Remove-GPPGroupsItem -SID "SID" -GPPSection $GPPSection -ItemType [GPPItemGroup]

        This command removes a GPP item with the SID "SID" from the specified GPP section.

    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
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

        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [GPPItemUserSubAuthority]
        $BuiltInUser,

        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [guid]
        $UID,

        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        [GPPSection]
        $GPPSection,

        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByGPONameObjectName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName')]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID')]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser')]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID')]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [Parameter(ParameterSetName = 'ByGPONameObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectLiteralName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectSID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionBuiltInUser', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdObjectUID', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPPSectionObjectUID', Mandatory = $true)]
        $ItemType,

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
            $workGPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
        } else {
            $workGPPSection = Get-GPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
        }
    } else {
        $workGPPSection = $GPPSection
    }

    $workObjects = $workGPPSection.Members | Where-Object -FilterScript { $_ -is $ItemType }
    if ($workObjects) {
        $paramGetFunction = @{
            GPPSection = $workGPPSection
        }

        if ($UID) {
            $paramGetFunction.Add('UID', $UID)
        } elseif ($ItemType -eq [GPPItemGroup] -and $SID) {
            $paramGetFunction.Add('SID', $SID)
        } elseif ($LiteralName) {
            $paramGetFunction.Add('LiteralName', $LiteralName)
        } elseif ($ItemType -eq [GPPItemUser] -and $BuiltInUser) {
            $paramGetFunction.Add('BuiltInUser', $BuiltInUser)
        } else {
            $paramGetFunction.Add('Name', $Name)
        }

        if ($DomainName) {
            $paramGetFunction.Add('DomainName', $DomainName)
        }

        $getFunctionName = switch ($ItemType) {
            ([GPPItemGroup]) {
                'Get-GPPGroup'
            }
            ([GPPItemUser]) {
                'Get-GPPUser'
            }
        }
        $filteredObjects = &$getFunctionName @paramGetFunction

        if ($filteredObjects) {
            foreach ($objectToRemove in $filteredObjects) {
                [void]$workGPPSection.Members.Remove($objectToRemove)
            }

            if ($GPPSection) {
                $workGPPSection
            } else {
                if ($DomainName) {
                    Set-GPPSection -InputObject $workGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups) -DomainName $DomainName
                } else {
                    Set-GPPSection -InputObject $workGPPSection -GPOId $GPOId -Context $Context -Type ([GPPType]::Groups)
                }
            }
        }
    }
}