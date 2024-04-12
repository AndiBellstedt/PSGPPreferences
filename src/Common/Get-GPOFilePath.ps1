function Get-GPOFilePath {
    Param (
        [guid]
        $Id,

        [string]
        $DomainName = $env:USERDNSDOMAIN
    )

    $PoliciesFolderPath = '\\{0}\SYSVOL\{0}\Policies' -f $DomainName
    Join-Path -Path $PoliciesFolderPath -ChildPath $GPOId.ToString('B') # B - 32 digits separated by hyphens, enclosed in braces: {00000000 - 0000 - 0000 - 0000 - 000000000000}
}