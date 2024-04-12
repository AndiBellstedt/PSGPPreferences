function Serialize-GPPSection {
    Param (
        [Parameter(Mandatory = $true)]
        [GPPSection]
        $InputObject,

        [switch]
        $IncludeType
    )

    switch ($InputObject.GetType().FullName) {
        'GPPSectionGroups' {
            $XMLDocument = Serialize-GPPSectionGroups -InputObject $InputObject
            $Type = [GPPType]::Groups
        }
    }

    if ($IncludeType) {
        @{
            XMLDocument = $XMLDocument
            Type        = $Type
        }
    } else {
        $XMLDocument
    }
}