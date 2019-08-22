
# https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key


function Run-Invoke-RestMethod {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$storageAccountKey,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$blobName,

        [Parameter(Mandatory)]
        [string]$httpAction,

        [string]$targetFolderPath
    )

    $verb = $httpAction
    $xMsVersion = "2015-02-21"
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    if ($targetFolderPath) {
        $targetFilePath = Join-Path -Path $targetFolderPath -ChildPath $blobName
    }
    $canonicalizedHeaders = "x-ms-date:$($xMsDate)`n" + "x-ms-version:$($xMsVersion)"
    $canonicalizedResource = "/$($storageAccountName)/$($containerName)/$($blobName)"
    $url = "https://$($storageAccountName).blob.core.windows.net/$($containerName)/$($blobName)"

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

    if ($targetFilePath) {
        Invoke-RestMethod -Uri $url -Method $verb -Headers $headers -OutFile $targetFilePath
    } else {
        Invoke-RestMethod -Uri $url -Method $verb -Headers $headers
    }
}


# List all the blob files in a specified container
function List-BlobFromAzure-XML {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$storageAccountKey,

        [Parameter(Mandatory)]
        [string]$containerName
    )

    $verb = "GET"
    $xMsVersion = "2015-02-21"
    $contentType = 'application/xml'
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    $canonicalizedHeaders = "x-ms-date:$($xMsDate)`n" + "x-ms-version:$($xMsVersion)"
    $canonicalizedResource = "/$($storageAccountName)/$($containerName)`ncomp:list`nrestype:container"
    $url = "https://$($storageAccountName).blob.core.windows.net/$($containerName)?restype=container&comp=list"

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
    return $responseXml
}

# Download the specified blob file in a container
function Download-BlobFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$storageAccountKey,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$blobName,

        [Parameter(Mandatory)]
        [string]$targetFolderPath
    )

    $results = List-BlobFromAzure-XML -storageAccountName $storageAccountName `
        -storageAccountKey $storageAccountKey -containerName $containerName

    if ($results.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blobName}) {
        "Find the $blobName and start to download it from $storageAccountName"
    } else {
        "Failed to download the $blobName on $storageAccountName because it doesn't exist"
        return "FAIL"
    }

    Run-Invoke-RestMethod -storageAccountName $storageAccountName -storageAccountKey $storageAccountKey `
        -containerName $containerName -blobName $blobName -httpAction "GET" `
        -targetFolderPath $targetFolderPath
}

# Download all blob files in a container
function Download-AllBlobsFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$storageAccountKey,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$targetFolderPath
    )

    $result = List-BlobFromAzure-XML -storageAccountName $storageAccountName `
        -storageAccountKey $storageAccountKey -containerName $containerName

    foreach ($blobFile in $result.EnumerationResults.Blobs.Blob.Name) {
        Write-OutPut "Download the $blobFile"
        Run-Invoke-RestMethod -storageAccountName $storageAccountName -storageAccountKey $storageAccountKey `
            -containerName $containerName -blobName $blobFile -httpAction "GET" `
            -targetFolderPath $targetFolderPath
    }
}

# Delete the specified blob file in a container
function Delete-BlobFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$storageAccountKey,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$blobName
    )

    $results = List-BlobFromAzure-XML -storageAccountName $storageAccountName `
        -storageAccountKey $storageAccountKey -containerName $containerName

    if ($results.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blobName}) {
        "Find the $blobName and start to delete it from $storageAccountName"
    } else {
        "Failed to delete the $blobName on $storageAccountName because it doesn't exist"
        return "FAIL"
    }

    Run-Invoke-RestMethod -storageAccountName $storageAccountName -storageAccountKey $storageAccountKey `
        -containerName $containerName -blobName $blobName -httpAction "DELETE"
}


$StorageAccount = "YourStorageAccountName"
$containerName = "YourContainerName"
$stAccountKey = "YourStorageAccountKey"
$targetFolderPath = "YourFolder"

$result = List-BlobFromAzure-XML -storageAccountName $StorageAccount `
    -storageAccountKey $stAccountKey -containerName $containerName
Write-OutPut "The blobs in ${containerName}:"
foreach ($item in $result.EnumerationResults.Blobs.Blob.Name) {
    Write-OutPut "$item"
}

$blobFileName = "YourBlobFileNameToBeDownloaded"
Download-BlobFromAzure -storageAccountName $StorageAccount -storageAccountKey $stAccountKey `
        -containerName $containerName -blobName $blobFileName -targetFolderPath $targetFolderPath

Download-AllBlobsFromAzure -storageAccountName $StorageAccount -storageAccountKey $stAccountKey `
        -containerName $containerName -targetFolderPath $targetFolderPath

$blobFileName = "YourBlobFileNameToBeDeleted"
Delete-BlobFromAzure -storageAccountName $StorageAccount -storageAccountKey $stAccountKey `
        -containerName $containerName -blobName $blobFileName
