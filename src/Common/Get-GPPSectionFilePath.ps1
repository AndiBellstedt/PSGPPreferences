function Get-GPPSectionFilePath {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(Mandatory = $true)]
        [GPPContext]
        $Context,

        [Parameter(Mandatory = $true)]
        [GPPType]
        $Type,

        [string]
        $DomainName,

        [switch]
        $Extended
    )

    if ($DomainName) {
        $policyPath = Get-GPOFilePath -Id $GPOId -DomainName $DomainName
    } else {
        $policyPath = Get-GPOFilePath -Id $GPOId
    }

    $contextPath = Join-Path -Path $policyPath -ChildPath ('{0}\Preferences' -f $Context)
    $folderPath = Join-Path -Path $contextPath -ChildPath $Type
    $filePath = Join-Path -Path $folderPath -ChildPath ('{0}.xml' -f $Type)

    if ($Extended) {
        @{
            FolderPath = $folderPath
            FilePath   = $filePath
        }
    } else {
        $filePath
    }
}