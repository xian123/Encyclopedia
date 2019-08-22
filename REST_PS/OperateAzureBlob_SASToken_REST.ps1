

function Run-Invoke-RestMethod {
    param (
        [string]$blobName,

        [Parameter(Mandatory)]
        [string]$httpAction,

        [Parameter(Mandatory)]
        [string]$url,

        [string]$contentType = "",
        [string]$targetFolderPath
    )

    $verb = $httpAction
    $xMsVersion = "2015-02-21"
    $xMsDate = [DateTime]::UtcNow.ToString('r')
    if ($targetFolderPath) {
        $targetFilePath = Join-Path -Path $targetFolderPath -ChildPath $blobName
    }

    $headers = @{
        "x-ms-version" = $xMsVersion
        "x-ms-date" = $xMsDate
        "Content-Type" = $contentType
    }

    if ($contentType) {
        $responseText = Invoke-RestMethod -Uri $url -Headers $headers -Method $verb -ContentType $contentType
        [xml]$responseXml = $responseText.Substring($responseText.IndexOf("<"))
        return $responseXml
    }

    if ($targetFilePath) {
        Invoke-RestMethod -Uri $url -Method $verb -Headers $headers -OutFile $targetFilePath
    } else {
        Invoke-RestMethod -Uri $url -Method $verb -Headers $headers
    }
}

# List all the blob files in a specified container
function List-BlobFromAzure-XML {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$SASToken,

        [Parameter(Mandatory)]
        [string]$containerName
    )

    $url = "https://$storageAccountName.blob.core.windows.net/$($containerName)/$SASToken&restype=container&comp=list"
    $result = Run-Invoke-RestMethod -httpAction "GET" -url $url -contentType 'application/xml'
    return $result
}

# Download the specified blob file in a container
function Download-BlobFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$blobName,

        [Parameter(Mandatory)]
        [string]$SASToken,

        [Parameter(Mandatory)]
        [string]$targetFolderPath
    )

    $result = List-BlobFromAzure-XML -storageAccountName $storageAccountName `
        -SASToken $SASToken -containerName $containerName

    if ($result.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blobName}) {
        "Find the $blobName and start to download it from $storageAccountName"
    } else {
        "Failed to download the $blobName on $storageAccountName because it doesn't exist"
        return "FAIL"
    }

    $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($BlobName)$SASToken"
    Run-Invoke-RestMethod -blobName $BlobName -httpAction "GET" -targetFolderPath $targetFolderPath -url $url
}

# Delete the specified blob file in a container
function Delete-BlobFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$containerName,

        [Parameter(Mandatory)]
        [string]$blobName,

        [Parameter(Mandatory)]
        [string]$SASToken
    )

    $result = List-BlobFromAzure-XML -storageAccountName $storageAccountName `
        -SASToken $SASToken -containerName $containerName

    if ($result.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blobName}) {
        "Find the $blobName and start to delete it from $storageAccountName"
    } else {
        "Failed to delete the $blobName on $storageAccountName because it doesn't exist"
        return "FAIL"
    }

    $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($BlobName)$SASToken"
    Run-Invoke-RestMethod -blobName $BlobName -httpAction "DELETE" -url $url
}

#############################################################################################

$storageAccount = "YourStorageAccountName"
$containerName = "YourContainerName"
$targetFolderPath = "YourFolder"
$SASToken = "YourSASToke"

$result = List-BlobFromAzure-XML -StorageAccountName $storageAccount -SASToken $SASToken -containerName $containerName
Write-OutPut "The blobs in ${containerName}:"
foreach ($item in $result.EnumerationResults.Blobs.Blob.Name) {
    Write-OutPut "    $item"
}
Write-OutPut "`n"

$BlobName = "BlobFileToBeDownloaded"
Download-BlobFromAzure -StorageAccountName $storageAccount -containerName $containerName `
    -blobName $BlobName -targetFolderPath $targetFolderPath -SASToken $SASToken

$BlobName = "BlobFileToBeDeleted"
Delete-BlobFromAzure -StorageAccountName $storageAccount -containerName $containerName `
    -blobName $BlobName -SASToken $SASToken
