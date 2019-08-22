
# https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key

# Download blob from Azure in PowerShell without AzureRM
# https://madridcentral.com/2018/03/19/download-blob-from-azure-in-powershell-without-azurerm/
# https://tsmatz.wordpress.com/2016/07/06/how-to-get-azure-storage-rest-api-authorization-header/


# PowerShell and Azure REST API Authentication
# https://datathirst.net/blog/2018/9/23/powershell-and-azure-rest-api-authentication


#
# Lets define our REST API call URI to list all blobs with their metadata (if available):
# $uriListBlobs = "https://YourStorageAccountName.blob.core.windows.net/YourContainerName/?comp=list&include=metadata&restype=container"
# Where
# comp=list => the list operation inside the vhds container 
# include=metadata => indicates the API to get any associated metadata (we need this when a page blob is attached to a VM) 
# restype=container => indicates that this operation is on a container resource type 
# For more information of available options, please refer to Blob Service REST API
# Blob Service REST API: https://docs.microsoft.com/en-us/rest/api/storageservices/Blob-Service-REST-API?redirectedfrom=MSDN
#

#
# Note: This script is just for test & debug NOT a release version!
#

function Get-BlobFromAzure {
    # [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$StorageAccountName,

        [Parameter(Mandatory)]
        [string]$StorageAccountKey,

        [Parameter(Mandatory)]
        [string]$ContainerName,

        [Parameter(Mandatory)]
        [string]$BlobName,

        [Parameter(Mandatory)]
        [string]$TargetFolderPath
    )

    $verb = "GET"
    $xMsVersion = "2015-02-21"
    $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($BlobName)"
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    $targetFilePath = Join-Path -Path $TargetFolderPath -ChildPath $BlobName
    $canonicalizedHeaders = "x-ms-date:$($xMsDate)`n" + "x-ms-version:$($xMsVersion)"
    $canonicalizedResource = "/$($StorageAccountName)/$($ContainerName)/$($BlobName)"

    $stringToSign = $verb + "`n" + `
        $contentEncoding + "`n" + `
        $contentLanguage + "`n" + `
        $contentLength + "`n" + `
        $contentMD5 + "`n" + `
        $contentType + "`n" + `
        $date + "`n" + `
        $ifModifiedSince + "`n" + `
        $ifMatch + "`n" + `
        $ifNoneMatch + "`n" + `
        $ifUnmodifiedSince + "`n" + `
        $range + "`n" + `
        $canonicalizedHeaders + "`n" + `
        $canonicalizedResource

    $hmac = new-object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Convert]::FromBase64String($storageAccountKey)
    $dataToMac = [System.Text.Encoding]::UTF8.GetBytes($stringToSign)
    $sigByte = $hmac.ComputeHash($dataToMac)
    $signature = [System.Convert]::ToBase64String($sigByte)

    $headers = @{
        "x-ms-version" = $xMsVersion
        "x-ms-date" = $xMsDate
        "Authorization" = "SharedKey $($storageAccountName):$($signature)"
    }

    Invoke-RestMethod -Uri $url -Method $verb -Headers $headers -OutFile $targetFilePath
}

$Blob = "YourBlobName"
$StorageAccount = "YourStorageAccountName"
$ContainerName = "YourContainerName"
$Key = "YourStorageAccountKey"
$TargetFolderPath = "YourFolder"

Get-BlobFromAzure -StorageAccountName $StorageAccount -StorageAccountKey $Key -ContainerName $ContainerName -BlobName $Blob -TargetFolderPath $TargetFolderPath

# https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
function List-BlobFromAzure {
    # [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$StorageAccountName,

        [Parameter(Mandatory)]
        [string]$StorageAccountKey,

        [Parameter(Mandatory)]
        [string]$ContainerName
    )

    $verb = "GET"
    $xMsVersion = "2015-02-21"
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    $canonicalizedHeaders = "x-ms-date:$($xMsDate)`n" + "x-ms-version:$($xMsVersion)"
    $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)?restype=container&comp=list"
    $canonicalizedResource = "/$($StorageAccountName)/$($ContainerName)`ncomp:list`nrestype:container"

    # Hit error if the `n is replaced with \n in PowerShell
    # $canonicalizedResource = "/$($StorageAccountName)/$($ContainerName)\ncomp:list\nrestype:container"
    # Invoke-RestMethod : AuthenticationFailedServer failed to authenticate the request. Make sure the value of Authorization header is formed correctly including the signature.
    # RequestId:a6762523-d01e-007b-73cd-5730d4000000
    # Time:2019-08-21T03:06:08.0233323ZThe MAC signature found in the HTTP request '9tlQQwg2OV0EVZo/4QTxF03K2P5bTN+xnMq6i2F8N6g=' is not the same as any computed signature. Server used following string to sign: 'GET

    $stringToSign = $verb + "`n" + `
        $contentEncoding + "`n" + `
        $contentLanguage + "`n" + `
        $contentLength + "`n" + `
        $contentMD5 + "`n" + `
        $contentType + "`n" + `
        $date + "`n" + `
        $ifModifiedSince + "`n" + `
        $ifMatch + "`n" + `
        $ifNoneMatch + "`n" + `
        $ifUnmodifiedSince + "`n" + `
        $range + "`n" + `
        $canonicalizedHeaders + "`n" + `
        $canonicalizedResource

    $hmac = new-object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Convert]::FromBase64String($storageAccountKey)
    $dataToMac = [System.Text.Encoding]::UTF8.GetBytes($stringToSign)
    $sigByte = $hmac.ComputeHash($dataToMac)
    $signature = [System.Convert]::ToBase64String($sigByte)

    $headers = @{
        "x-ms-version" = $xMsVersion
        "x-ms-date" = $xMsDate
        "Authorization" = "SharedKey $($storageAccountName):$($signature)"
    }

    Invoke-RestMethod -Uri $url -Method $verb -Headers $headers
}

$StorageAccount = "YourStorageAccountName"
$ContainerName = "YourContainerName"
$Key = "YourStorageAccountKey"

List-BlobFromAzure -StorageAccountName $StorageAccount -StorageAccountKey $Key -ContainerName $ContainerName

# Working with Azure REST APIs from Powershell – Getting page and block blob information from ARM based storage account sample script:
# https://blogs.technet.microsoft.com/paulomarques/2016/04/05/working-with-azure-rest-apis-from-powershell-getting-page-and-block-blob-information-from-arm-based-storage-account-sample-script/

function List-BlobFromAzure-XML {
    # [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$StorageAccountName,

        [Parameter(Mandatory)]
        [string]$StorageAccountKey,

        [Parameter(Mandatory)]
        [string]$ContainerName
    )

    $verb = "GET"
    $contentType = 'application/xml'
    $xMsVersion = "2015-02-21"
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    $canonicalizedHeaders = "x-ms-date:$($xMsDate)`n" + "x-ms-version:$($xMsVersion)"
    $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)?restype=container&comp=list"
    $canonicalizedResource = "/$($StorageAccountName)/$($ContainerName)`ncomp:list`nrestype:container"

    $stringToSign = $verb + "`n" + `
        $contentEncoding + "`n" + `
        $contentLanguage + "`n" + `
        $contentLength + "`n" + `
        $contentMD5 + "`n" + `
        $contentType + "`n" + `
        $date + "`n" + `
        $ifModifiedSince + "`n" + `
        $ifMatch + "`n" + `
        $ifNoneMatch + "`n" + `
        $ifUnmodifiedSince + "`n" + `
        $range + "`n" + `
        $canonicalizedHeaders + "`n" + `
        $canonicalizedResource

    $hmac = new-object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Convert]::FromBase64String($storageAccountKey)
    $dataToMac = [System.Text.Encoding]::UTF8.GetBytes($stringToSign)
    $sigByte = $hmac.ComputeHash($dataToMac)
    $signature = [System.Convert]::ToBase64String($sigByte)

    $headers = @{
        "x-ms-version" = $xMsVersion
        "x-ms-date" = $xMsDate
        "Content-Type" = $contentType
        "Authorization" = "SharedKey $($storageAccountName):$($signature)"
    }

    $responseText = Invoke-RestMethod -Uri $url -Headers $headers -Method $verb -ContentType $contentType
    [xml]$responseXml = $responseText.Substring($responseText.IndexOf("<"))
    "The blobs in $ContainerName : $($responseXml.EnumerationResults.Blobs.Blob.Name)"
}

$StorageAccount = "YourStorageAccountName"
$ContainerName = "YourContainerName"
$Key = "YourStorageAccountKey"

List-BlobFromAzure-XML -StorageAccountName $StorageAccount -StorageAccountKey $Key -ContainerName $ContainerName



#################################### Get Table ##################################### Start

# Querying Azure Table Service using the RestAPI and PowerShell
# https://blog.kloud.com.au/2019/02/05/loading-and-querying-data-in-azure-table-storage-using-powershell/

$StorageAccount = "YourStorageAccountName"
$storageAccountName = "YourStorageAccountName"
$ContainerName = "YourContainerName"
$Key = "YourStorageAccountKey"
$storageAccountkey = "YourStorageAccountKey"

$tableName = "YourTableName"
$apiVersion = "2017-04-17"
$tableURL = "https://$($storageAccountName).table.core.windows.net/$($tableName)"

$GMTime = (Get-Date).ToUniversalTime().toString('R')
$string = "$($GMTime)`n/$($storageAccountName)/$($tableName)"
$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Convert]::FromBase64String($storageAccountkey)
$signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($string))
$signature = [Convert]::ToBase64String($signature)

$headers = @{
    Authorization  = "SharedKeyLite " + $storageAccountName + ":" + $signature
    Accept         = "application/json;odata=fullmetadata"
    'x-ms-date'    = $GMTime
    "x-ms-version" = $apiVersion
}

$queryURL = "$($tableURL)"
$NICitem = Invoke-RestMethod -Method GET -Uri $queryURL -Headers $headers -ContentType application/json
$NICitem
$NICitem.value

#################################### Get Table ##################################### Done


# SAS Token

$ContainerName = "YourContainerName"
$StorageAccount = "YourStorageAccountName"
$SASToken = "YourSASToken"

Invoke-RestMethod -Method Get -Uri "https://$StorageAccount.blob.core.windows.net/$($containerName)/$SASToken&restype=container&comp=list"


# https://github.com/Azure/azure-powershell/issues/5053

# For list containers of a Storage account, server request the SAS token must be an Account SAS, 
# but can't be a container/blob SAS. And the SAS token need at least: -Service Blob -ResourceType Service -Permission l (list).


# Please make sure:
# Can the SAS be used to run other storage request on same storage account? Like create container?
# What's the "Azure.Storage" Module version? (Get it by run "Get-Module") On my machine which installed Azure Powershell 5.5.0, the version is 4.2.0
# Please add "-debug" to Get-azureStorageContainer cmdlets, then show the result. 
# Then we can see the request ID and do more investigation. (in the picture from you, the "-debug" is not added.)


# Please note the place of $SASToken
# Invoke-RestMethod -Method Get -Uri "https://$StorageAccount.blob.core.windows.net/$($containerName)/$SASToken&restype=container&comp=list"
# If the place of $SASToken is wrong like the below:
# Invoke-RestMethod -Method Get -Uri "https://$StorageAccount.blob.core.windows.net/$($containerName)&restype=container&comp=list$SASToken"
# You'll hit the error: sr is mandatory. Cannot be empty

# https://stackoverflow.com/questions/49138941/use-azure-table-sas-token-to-read-data-using-invoke-restmethod
# SAS Tokens are not valid in the Authorization header. They are only valid as a collection of query string parameters.
# See https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1 for more info about Azure Storage SAS tokens.

# Notice the SAS token is part of the $tableUri variable and not part of the header

# Create an account SAS: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas


