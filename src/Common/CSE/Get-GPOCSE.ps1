function Get-GPOCSE {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [string]
        $DomainName
    )

    if ($DomainName) {
        $gpo = Get-GPOObject -Id $Id -DomainName $DomainName
    } else {
        $gpo = Get-GPOObject -Id $Id
    }
    $attributeString = $gpo.gPCMachineExtensionNames[0]

    $listsRegExFilter = '(?i)(\[\{00000000-0000-0000-0000-000000000000\}(?<Tools>(?:\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})*)\])*(?<CseSets>(?:\[(?:\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})(?:\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})*\])*)'
    $listsRegEx = [regex]::new($listsRegExFilter)
    $listMatches = $listsRegEx.Matches($attributeString)

    # $ToolsList = ($listMatches.Groups | Where-Object -FilterScript { $_.Name -eq 'Tools' }).Value
    # All tools are listed under respecstive

    $cseSetsList = ($listMatches.Groups | Where-Object -FilterScript { $_.Name -eq 'CseSets' }).Value

    $eseSetsSplitRegExFilter = '(?i)(\[(?:\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})+\])'
    $cseSetsSplitRegEx = [regex]::new($eseSetsSplitRegExFilter)
    $cseSets = $cseSetsSplitRegEx.Matches($cseSetsList).Value

    foreach ($set in $cseSets) {
        $cseSetSplitRegExFilter = '(?i)\[(?<CSE>\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})(?<Tools>(?:\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})*)\]'
        $cseSetSplitRegEx = [regex]::new($cseSetSplitRegExFilter)
        $cseSetSplitted = $cseSetSplitRegEx.Matches($set)
        $cseId = ($cseSetSplitted.Groups | Where-Object -FilterScript { $_.Name -eq 'CSE' }).Value
        $cseToolsList = ($cseSetSplitted.Groups | Where-Object -FilterScript { $_.Name -eq 'Tools' }).Value

        $toolsFilter = '(?i)\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}'
        $toolsRegEx = [regex]::new($toolsFilter)
        $toolsId = $toolsRegEx.Matches($cseToolsList).Value

        [GpoCseSet]::new($cseId, $toolsId)
    }
}
