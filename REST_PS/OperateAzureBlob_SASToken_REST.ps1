

<#
How to run this script:

Step 1: Download the script to local, e.g, D:, then change directory to D
Step 2: Initialize the below parameters

    $storageAccountName = "YourStorageAccountName"
    $containerName = "YourContainerName"
    $targetFolderPath = "WhereFilesAreSaved" # Default valure is current directory if it's null
    $SASToken = "YourSASToken"

Step 3: Run the script. The below are some examples.

# Example 1: List the blobs and download all of them
./OperateAzureBlob_SASToken_REST.ps1 -Download "all" -storageAccount $storageAccountName -containerName $containerName `
    -SASToken $SASToken -targetFolderPath $targetFolderPath -List

# Example 2: Download the specified file(s), multiple files split with comma
./OperateAzureBlob_SASToken_REST.ps1 -Download "linux.vhd,freebsd.vhd" -storageAccount $storageAccountName `
    -containerName $containerName -SASToken $SASToken -targetFolderPath $targetFolderPath

# Example 3: List the blobs and delete all of them
./OperateAzureBlob_SASToken_REST.ps1 -Delete "all" -storageAccount $storageAccountName -containerName $containerName `
    -SASToken $SASToken -targetFolderPath $targetFolderPath -List

# Example 4: Delete the specified file(s), multiple files split with comma
./OperateAzureBlob_SASToken_REST.ps1 -Delete "linux.vhd,freebsd.vhd" -storageAccount $storageAccountName `
    -containerName $containerName -SASToken $SASToken

# Example 5: List the blobs
./OperateAzureBlob_SASToken_REST.ps1 -storageAccount $storageAccountName -containerName $containerName `
    -SASToken $SASToken -targetFolderPath $targetFolderPath -List

#>

param (
    [string]$Download,
    [string]$Delete,
    [switch] $List,

    [Parameter(Mandatory)]
    [string]$storageAccount,
    
    [Parameter(Mandatory)]
    [string]$containerName,

    [Parameter(Mandatory)]
    [string]$SASToken,

    [string]$targetFolderPath
)

function Run-InvokeRestMethod {
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
function List-BlobFromAzure {
    param (
        [Parameter(Mandatory)]
        [string]$storageAccountName,

        [Parameter(Mandatory)]
        [string]$SASToken,

        [Parameter(Mandatory)]
        [string]$containerName
    )

    $url = "https://$storageAccountName.blob.core.windows.net/$($containerName)/$SASToken&restype=container&comp=list"
    $result = Run-InvokeRestMethod -httpAction "GET" -url $url -contentType 'application/xml'
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

    $result = List-BlobFromAzure -storageAccountName $storageAccountName `
        -SASToken $SASToken -containerName $containerName

    if ($blobName -eq "all") {
        foreach ($blob in $result.EnumerationResults.Blobs.Blob.Name) {
            $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($blob)$SASToken"
            Run-InvokeRestMethod -blobName $blob -httpAction "GET" -targetFolderPath $targetFolderPath -url $url
            "Download $blob successfully"
        }
    } else {
        foreach ($blob in $blobName.split(",")) {
            if ($result.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blob}) {
            "Find the $blob and start to download it from $storageAccountName"
            } else {
                "Failed to download the $blob on $storageAccountName because it doesn't exist"
                continue
            }

            $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($blob)$SASToken"
            Run-InvokeRestMethod -blobName $blob -httpAction "GET" -targetFolderPath $targetFolderPath -url $url
            "Download $blob successfully"
        }
    }
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

    $result = List-BlobFromAzure -storageAccountName $storageAccountName `
        -SASToken $SASToken -containerName $containerName

    if ($blobName -eq "all") {
        foreach ($blob in $result.EnumerationResults.Blobs.Blob.Name) {
            $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($blob)$SASToken"
            Run-InvokeRestMethod -blobName $blob -httpAction "DELETE" -url $url
            "Delete $blob successfully"
        }
    } else {
        foreach ($blob in $blobName.split(",")) {
            if ($result.EnumerationResults.Blobs.Blob | ? {$_.name -eq $blob}) {
            "Find the $blob and start to delete it from $storageAccountName"
            } else {
                "Failed to delete the $blob on $storageAccountName because it doesn't exist"
                continue
            }

            $url = "https://$($StorageAccountName).blob.core.windows.net/$($ContainerName)/$($blob)$SASToken"
            Run-InvokeRestMethod -blobName $blob -httpAction "DELETE" -url $url
            "Delete $blob successfully"
        }
    }
}

####################################### Main ######################################################

if (-not $targetFolderPath) {
    $targetFolderPath = pwd
} 

if (!(Test-Path $targetFolderPath)) {
    New-Item -Path $targetFolderPath -ItemType Directory -Force | Out-Null
}

Write-OutPut "Storage account name: $storageAccount"
Write-OutPut "Container name: $containerName"
Write-OutPut "The target path: $targetFolderPath`n"


if ($List) {
    $result = List-BlobFromAzure -StorageAccountName $storageAccount -SASToken $SASToken -containerName $containerName
    Write-OutPut "The blobs in ${containerName}:"
    foreach ($item in $result.EnumerationResults.Blobs.Blob.Name) {
        Write-OutPut "    $item"
    }
    Write-OutPut "`n"
}

if ($Download) {
    Download-BlobFromAzure -StorageAccountName $storageAccount -containerName $containerName `
        -blobName $Download -targetFolderPath $targetFolderPath -SASToken $SASToken
}

if ($Delete) {
    Delete-BlobFromAzure -StorageAccountName $storageAccount -containerName $containerName `
        -blobName $Delete -SASToken $SASToken
}

