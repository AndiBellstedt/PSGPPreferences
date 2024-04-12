function Set-GPOCSE {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [Parameter(Mandatory = $true)]
        [string]
        $Value,

        [string]
        $DomainName
    )

    if ($DomainName) {
        $gpo = Get-GPOObject -Id $Id -DomainName $DomainName
    } else {
        $gpo = Get-GPOObject -Id $Id
    }

    $gpo.InvokeSet('gPCMachineExtensionNames', $Value)
    $gpo.CommitChanges()
}