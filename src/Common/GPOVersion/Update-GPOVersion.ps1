function Update-GPOVersion {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [string]
        $DomainName
    )

    if ($DomainName) {
        $gpoItem = Get-GPOObject -Id $Id -DomainName $DomainName
    } else {
        $gpoItem = Get-GPOObject -Id $Id
    }

    [int]$gpoVersionNumber = $gpo.versionNumber | Select-Object -First 1 # System.DirectoryServices.PropertyValueCollection, that's why we have to access the first element
    $gpoVersionNumber++
    $gpoItem.versionNumber = $GPOVersionNumber
    $gpoItem.CommitChanges()

    if ($DomainName) {
        Update-GPOFileVersion -Id $Id -Version $GPOVersionNumber -DomainName $DomainName
    } else {
        Update-GPOFileVersion -Id $Id -Version $GPOVersionNumber
    }
}