function Set-GPPSection {
    Param (
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [GPPSection]
        $InputObject,

        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [string]
        $GPOName,

        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [guid]
        $GPOId,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ById')]
        [GPPContext]
        $Context = $ModuleWideDefaultGPPContext,

        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [GPPType]
        $Type,

        [string]
        $DomainName
    )

    if (-not $GPOId) {
        if ($DomainName) {
            $GPOId = Convert-GPONameToID -Name $GPOName -DomainName $DomainName
        } else {
            $GPOId = Convert-GPONameToID -Name $GPOName
        }
    }

    $sectionDescription = Serialize-GPPSection -InputObject $InputObject -IncludeType

    $xmlDocument = $sectionDescription.XMLDocument
    if (-not $Type) {
        $Type = $sectionDescription.Type
    }

    if ($DomainName) {
        $gppSectionFilePathResult = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type -Extended -DomainName $DomainName
    } else {
        $gppSectionFilePathResult = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type -Extended
    }
    $filePath = $gppSectionFilePathResult.FilePath
    $folderPath = $gppSectionFilePathResult.FolderPath

    if (-not (Test-Path -Path $folderPath)) {
        $null = New-Item -Path $folderPath -ItemType Directory
    }

    if ($xmlDocument.OuterXml) {
        Set-Content -Path $filePath -Value $xmlDocument.OuterXml
        if ($DomainName) {
            Update-GPOMetadata -Id $GPOId -Type $Type -DomainName $DomainName
        } else {
            Update-GPOMetadata -Id $GPOId -Type $Type
        }
    } else {
        Remove-Item -Path $filePath
        if ($DomainName) {
            Update-GPOMetadata -Id $GPOId -Type $Type -Remove -DomainName $DomainName
        } else {
            Update-GPOMetadata -Id $GPOId -Type $Type -Remove
        }
    }
}
