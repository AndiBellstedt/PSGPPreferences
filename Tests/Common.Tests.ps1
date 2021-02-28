BeforeDiscovery {
    $ScriptDirectoryPath = $PSScriptRoot
    $ModuleRootPath = Join-Path -Path $ScriptDirectoryPath -ChildPath ..\
    Import-Module -Name (Join-Path -Path $ModuleRootPath -ChildPath 'PSGPPreferences.psd1') -Force
    . (Join-Path -Path $ModuleRootPath -ChildPath 'Definitions\Classes.ps1')
}

Describe 'Internal functions' {
    InModuleScope PSGPPreferences {
        Describe 'UNIT: Initialize-GPPSection' {

            $InitializeGPPSectionOutput = Initialize-GPPSection
            $TestCases = @(
                @{
                    InitializeGPPSectionOutput = $InitializeGPPSectionOutput
                }
            )
            It 'Ensures the result is an XML document' -TestCases $TestCases {
                $InitializeGPPSectionOutput -is [System.Xml.XmlDocument] | Should -Be $true
            }

            It 'Ensures the XML document is correct' -TestCases $TestCases {
                ($InitializeGPPSectionOutput).outerXml | Should -Be '<?xml version="1.0" encoding="utf-8"?>'
            }
        }

        Describe 'UNIT: Convert-GPONameToID' {
            # Impossible to test due to dependency on the System.DirectoryServices.DirectorySearcher class and we can't mock classes yet.
        }
    }
}