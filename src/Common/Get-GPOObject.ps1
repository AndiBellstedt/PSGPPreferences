function Get-GPOObject {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [string]
        $DomainName
    )

    if ($DomainName) {
        $domainDN = ([System.DirectoryServices.DirectoryEntry]::new("LDAP://$($DomainName)")).DistinguishedName
    } else {
        $domainDN = ([System.DirectoryServices.DirectoryEntry]::new("LDAP://RootDSE")).defaultNamingContext
    }

    $idFormatted = $Id.ToString('B')
    #$gpoLdapPath = 'LDAP://CN={0},CN=Policies,CN=System,{1}' -f $idFormatted, $domainDN
    $adsiSearcher = [adsisearcher]::new(
        [adsi]"LDAP://CN=Policies,CN=System,$($domainDN)",
        "(cn=$($idFormatted))"
    )
    $output = $adsiSearcher.FindOne()
    $output.GetDirectoryEntry()
    #$gpo = $output
    #[System.DirectoryServices.DirectoryEntry]::new($gpoLdapPath)
}