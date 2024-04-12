function Get-GPPSection {
    Param (
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

    if ($DomainName) {
        $FilePath = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type -DomainName $DomainName
    } else {
        $FilePath = Get-GPPSectionFilePath -GPOId $GPOId -Context $Context -Type $Type
    }

    $FilePathExistence = Test-Path -Path $FilePath

    if ($FilePathExistence) {
        [xml]$XmlDocument = Get-Content -Path $FilePath

        Deserialize-GPPSection -InputObject $XmlDocument
    }
}