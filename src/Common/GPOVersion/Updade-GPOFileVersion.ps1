function Update-GPOFileVersion {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [Parameter(Mandatory = $true)]
        [int]
        $Version,

        [string]
        $DomainName
    )

    if ($DomainName) {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
            [System.DirectoryServices.ActiveDirectory.DirectoryContext]::new( [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain , $DomainName )
        )
    } else {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    }
    $domainDnsName = $domain.Name

    $idFormatted = $Id.ToString('B')
    $gpoFSPath = '\\{0}\SYSVOL\{0}\Policies\{1}' -f $domainDnsName, $idFormatted
    $gptIniPath = Join-Path -Path $gpoFSPath -ChildPath 'GPT.INI'
    $fileContent = "[General]`nVersion={0}" -f $Version # GPO AD DS version is more important than the version in the file

    Set-Content -Path $gptIniPath -Value $fileContent
}