function Update-GPOMetadata {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [Parameter(Mandatory = $true)]
        [GPPType]
        $Type,

        [string]
        $DomainName,

        [switch]
        $Remove
    )

    if ($DomainName) {
        Update-GPOVersion -Id $Id -DomainName $DomainName

        Update-GPOCSE -Id $Id -Type $Type -DomainName $DomainName -Remove:$Remove
    } else {
        Update-GPOVersion -Id $Id

        Update-GPOCSE -Id $Id -Type $Type -Remove:$Remove
    }
}