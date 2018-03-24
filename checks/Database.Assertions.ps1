<# It is important to test our test. It really is. 
 # (http://jakubjares.com/2017/12/07/testing-your-environment-tests/)
 #
 #   To be able to do it with Pester one has to keep the test definition and the assertion 
 # in separate files. Write a new test, or modifying an existing one typically involves 
 # modifications to the three related files:
 #
 # /checks/Database.Assertions.ps1 (this file)              - where the assertions are defined
 # /checks/Database.Tests.ps1                               - where the assertions are used to check stuff
 # /tests/checks/Database.Assetions.Tests.ps1               - where the assertions are unit tests
 #>
 
function Get-SettingsForDatabaseCollactionCheck {#
    $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
    return @{
        WrongCollation = $Wrongcollation
        ExcludedDatabase = @("ReportingServer", "ReportingServerTempDB")+@($Wrongcollation)
    }
}

function Assert-DatabaseCollation {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true,Position=0)]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if ($TestObject.Database -in $TestSettings.ExcludedDatabase) {
            # if it is one of the excluded databases than we expect the database collation not to match the server one
            $TestObject.DatabaseCollation | Should -Not -Be $TestObject.ServerCollation -Because $Because 
        } else { 
            # otherwise it should match
            $TestObject.DatabaseCollation | Should -Be $TestObject.ServerCollation -Because $Because 
        }
    }
}

function Get-SettingsForDatabaseOwnerIsValid {
    return @{
        ExpectedOwner = @(Get-DbcConfigValue policy.validdbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.validdbowner.excludedb)
    }
}

function Assert-DatabaseOwnerIsValid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true,Position=0)]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $TestSettings.ExcludedDatabase)) {
            $TestObject.CurrentOwner | Should -BeIn $TestSettings.ExpectedOwner -Because $Because
        }
    }
}

function Get-SettingsForDatabaseOwnerIsNotInvalid {
    return @{
        InvalidOwner = @(Get-DbcConfigValue policy.invaliddbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.invaliddbowner.excludedb)
    }
}

function Assert-DatabaseOwnerIsNotInvalid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true,Position=0)]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $TestSettings.ExcludedDatabase)) {
            $TestObject.CurrentOwner | Should -Not -BeIn $TestSettings.InvalidOwner -Because $Because
        }
    }
}

function Assert-RecoveryModel {
    param (
        [object]$TestObject,
        [string]$ExpectedRecoveryModel,
        [string]$Because
    )
    $TestObject.RecoveryModel | Should -Be $ExpectedRecoveryModel -Because $Because
}

function Assert-SuspectPageCount {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [string]$Because
    )
    process {
        $TestObject.SuspectPages | Should -Be 0 -Because $Because
    }
}