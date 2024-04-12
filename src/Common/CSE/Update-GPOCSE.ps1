function Update-GPOCSE {
    Param (
        [Parameter(Mandatory = $true)]
        [guid]
        $Id,

        [Parameter(Mandatory = $true)]
        [GPPType]
        $Type,

        [string]
        $DomainName,

        [switch]
        $Remove
    )

    $notContains = $false

    if ($DomainName) {
        $enabledCSEs = Get-GPOCSE -Id $Id -DomainName $DomainName
    } else {
        $enabledCSEs = Get-GPOCSE -Id $Id
    }

    $currentCSESet = [GPPCSE]::GetCseSetByType($Type)
    if ($enabledCSEs) {
        if ($enabledCSEs.CSE -notcontains $currentCSESet.CSE) { $notContains = $true }
    } else {
        $notContains = $true
    }

    $cseAttribute = $null
    if ($notContains -and -not $Remove) {
        $cseAttribute = [GPOExtensionNamesAttribute]::new($currentCSESet)

        [void]$cseAttribute.Members.Add($enabledCSEs)
    } elseif (-not $notContains -and $Remove) {
        $cseAttribute = [GPOExtensionNamesAttribute]::new($enabledCSEs)
        $MemberToRemove = $cseAttribute.Members | Where-Object -FilterScript { $_.CSE -eq $currentCSESet.CSE }

        [void]$cseAttribute.Members.Remove($MemberToRemove)
    }

    if ($cseAttribute) {
        $cseAttributeString = $cseAttribute.ToString()

        if ($DomainName) {
            Set-GPOCSE -Id $Id -Value $cseAttributeString -DomainName $DomainName
        } else {
            Set-GPOCSE -Id $Id -Value $cseAttributeString
        }
    }
}