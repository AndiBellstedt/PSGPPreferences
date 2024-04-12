function New-GPPGroup {
    <#
    .SYNOPSIS
        Creates a new Group Policy Preferences group definition.

    .DESCRIPTION
        Creates a new Group Policy Preferences group definition.
        You can either save it in the memory for additional processing
        or immediately put into a GPO by using the -GPOName or -GPOId parameters.

        Note that available parameters depend on the action
        you choose: -Create, -Replace, -Update, or -Delete. This mimics the GUI behavior.

    .PARAMETER Name
        Specifies the name of a group.
        This is a mandatory parameter for all operations.

    .PARAMETER SID
        The Security Identifier (SID) of the group. This is a mandatory parameter for all operations.

    .PARAMETER Create
        A switch parameter to indicate that a new group should be created.

    .PARAMETER Replace
        A switch parameter to indicate that the group should be replaced.

    .PARAMETER Update
        A switch parameter to indicate that the group should be updated.

    .PARAMETER Delete
        A switch parameter to indicate that the group should be deleted.

    .PARAMETER Disable
        Disables processing of this group object. In the GUI you'll see it greyed out.

    .PARAMETER Members
        Specifies which group members should be set for this group.
        Use New-GPPGroupMember to create them.

    .PARAMETER GPOName
        Specifies the name of a GPO into which you want to add the newly created group definition.

    .PARAMETER GPOId
        Specifies the ID of a GPO in which you want to search for users.
        It is a name of a Group Policy's object in Active Directory.
        Look into a CN=Policies,CN=System container in your AD DS domain.

    .PARAMETER Context
        Specifies which Group Policy context to use: Machine or User.
        Doesn't do anything right now, since the User one has not yet been implemented.

    .PARAMETER NewName
        The new name of the group, if it is being updated.
        Specifies the new name of a group if you want to rename it on target hosts.

    .PARAMETER Description
        Sets the description of a group object.

    .PARAMETER DeleteAllGroups
        Sets the DeleteAllGroups attribute at the group object.

    .PARAMETER DeleteAllUsers
        A switch parameter to indicate that all users in the group should be deleted.

    .PARAMETER DomainName
        The name of the domain in which the GPO resides.

    .PARAMETER PassThru
        Returns a new group definition object to the pipeline.

    .EXAMPLE
        PS C:> New-GPPGroup -Name 'TEST-1' -GPOName 'Custom Group Policy' -Create -Members $Members

        Creates a new group definition for a group called "TEST-1" with its action set to "Create" and using $Members as members for this group. The definition is saved in a GPO called "Custom Group Policy".

        $Members can be created using the New-GPPGroupMember cmdlet. For example:
        $Members = New-GPPGroupMember -SID 'S-1-5-21-2571216883-1601522099-2002488368-500'

    .EXAMPLE
        PS C:> New-GPPGroup -Name 'TEST-1' -GPOId '70f86590-588a-4659-8880-3d2374604811' -Delete

        Creates a new group definition for a group called "TEST-1" with its action set to "Delete", and saves it in a GPO with ID 70f86590-588a-4659-8880-3d2374604811.

    .EXAMPLE
        PS C:> $GroupDef = New-GPPGroup -SID 'S-1-5-32-547' -Update -Members (New-GPPGroupMember -Name 'EXAMPLE\SupportGroup' -Action ADD)

        Creates a new group definition with "EXAMPLE\SupportGroup" as group member and "Update" as its action. The definition specifies the group by SID rather its name. S-1-5-32-547 means "Power Users".
Note that this group definition is not saved in any group policy object - it exists only in memory. You can modify it and later save in a GPO using Add-GPPGroup.

    .EXAMPLE
        PS C:> New-GPPGroup -Name 'TEST-1' -Replace -GPOName 'Custom Group Policy' -Members @((New-GPPGroupMember -Name 'EXAMPLE\Administrator' -Action ADD),(New-GPPGroupMember -Name 'EXAMPLE\SupportGroup' -Action ADD)) -Disable

        Creates a new group definition in a GPO named "Custom Group Policy", with "EXAMPLE\Administrator" and "EXAMPLE\SupportGroup" as group members. The group definition will be in a disabled state and its action is "Replace".

    #>
    [CmdletBinding()]
    [OutputType('GPPItemGroup', ParameterSetName = ('ByGroupNameCreate', 'ByGroupNameReplace', 'ByGroupNameUpdate', 'ByGroupNameDelete', 'ByGroupSIDCreate', 'ByGroupSIDReplace', 'ByGroupSIDUpdate', 'ByGroupSIDDelete'))]
    Param (
        [Parameter(ParameterSetName = 'ByGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory = $true)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory = $true)]
        [System.Security.Principal.SecurityIdentifier]
        $SID,

        [Parameter(ParameterSetName = 'ByGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory = $true)]
        [switch]
        $Create,

        [Parameter(ParameterSetName = 'ByGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory = $true)]
        [switch]
        $Replace,

        [Parameter(ParameterSetName = 'ByGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory = $true)]
        [switch]
        $Update,

        [Parameter(ParameterSetName = 'ByGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGroupSIDDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory = $true)]
        [switch]
        $Delete,

        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameDelete')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameDelete')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDDelete')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [string]
        $NewName,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [string]
        $Description,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]
        $DeleteAllUsers,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]
        $DeleteAllGroups,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]
        $Disable,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [GPPItemGroupMember[]]
        $Members,

        [string]
        $DomainName,

        [Parameter(ParameterSetName = 'ByGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameCreate')]
        [Parameter(ParameterSetName = 'ByGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDCreate')]
        [Parameter(ParameterSetName = 'ByGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameReplace')]
        [Parameter(ParameterSetName = 'ByGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDReplace')]
        [Parameter(ParameterSetName = 'ByGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupNameUpdate')]
        [Parameter(ParameterSetName = 'ByGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPONameGroupSIDUpdate')]
        [Parameter(ParameterSetName = 'ByGPOIdGroupSIDUpdate')]
        [switch]
        $PassThru
    )

    if ($SID) {
        $Name = [System.Security.Principal.SecurityIdentifier]::new($SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    $action = if ($Create) {
        [GPPItemAction]::C
    } elseif ($Replace) {
        [GPPItemAction]::R
    } elseif ($Update) {
        [GPPItemAction]::U
    } else {
        [GPPItemAction]::D
    }

    $properties = [GPPItemPropertiesGroup]::new($action, $Name, $SID, $NewName, $Description, $Members, $DeleteAllUsers, $DeleteAllGroups)
    $group = [GPPItemGroup]::new($properties, $Disable)

    if ($GPOName -or $GPOId) {
        $paramAddGPPGroup = @{
            InputObject = $group
            Context     = $Context
        }

        if ($GPOId) {
            $paramAddGPPGroup.Add('GPOId', $GPOId)
        } else {
            $paramAddGPPGroup.Add('GPOName', $GPOName)
        }

        if ($DomainName) {
            $paramAddGPPGroup.Add('DomainName', $DomainName)
        }

        if ($PassThru) {
            $group
        }
        Add-GPPGroup @paramAddGPPGroup
    } else {
        $group
    }
}
