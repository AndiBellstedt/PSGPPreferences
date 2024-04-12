function Convert-DateTimeToGPPExpirationDate {
    [OutputType('string')]
    Param (
        [Parameter(Mandatory = $true)]
        [datetime]
        $DateTime
    )

    '{0:yyyy}-{0:MM}-{0:dd}' -f $DateTime
}