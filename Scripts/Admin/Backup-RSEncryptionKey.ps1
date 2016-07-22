# Copyright (c) 2016 Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT License (MIT)

function Backup-RSEncryptionKey
{
    <#
    .SYNOPSIS
        This script creates a back up of the SQL Server Reporting Services encryption key.

    .DESCRIPTION
        This script creates a back up of the encryption key for SQL Server Reporting Services. This key is needed in order to read all the encrypted content stored in the Reporting Services Catalog database.

    .PARAMETER SqlServerInstance 
        Specify the name of the SQL Server Reporting Services Instance.

    .PARAMETER SqlServerVersion 
        Specify the version of the SQL Server Reporting Services Instance. 13 for SQL Server 2016, 12 for SQL Server 2014, 11 for SQL Server 2012

    .PARAMETER Password
        Specify the password to be used for backing up the encryption key. This password will be required when restoring the encryption key.
        
    .PARAMETER KeyPath
        Specify the path to where the encryption key should be stored. 
    #>
    
    param(
        [string]$SqlServerInstance='MSSQLSERVER',
        [string]$SqlServerVersion='13',

        [Parameter(Mandatory=$True)]
        [string]$Password,
        
        [Parameter(Mandatory=$True)]
        [string]$KeyPath    
    )

    $rsWmiObject = New-RSConfigurationSettingObject -SqlServerInstance $SqlServerInstance -SqlServerVersion $SqlServerVersion

    Write-Host "Retrieving encryption key..."
    $encryptionKeyResult = $rsWmiObject.BackupEncryptionKey($Password)

    if ($encryptionKeyResult.HRESULT -eq 0) {
        Write-Host "Success!";
    } else {
        Write-Error "Fail! `n Errors: $($encryptionKeyResult.ExtendedErrors)";
        Exit 1
    }

    Write-Host "Writing key to file..."
    [System.IO.File]::WriteAllBytes($KeyPath, $encryptionKeyResult.KeyFile)
    Write-Host "Success!"
}
