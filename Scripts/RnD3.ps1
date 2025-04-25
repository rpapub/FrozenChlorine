function Get-AccessToken {
    param (
        [string]$TokenUrl,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$Scope
    )

    # Prepare the body of the request using URL encoding
    $body = "grant_type=client_credentials&client_id=$([Uri]::EscapeDataString($ClientId))&client_secret=$([Uri]::EscapeDataString($ClientSecret))&scope=$([Uri]::EscapeDataString($Scope))"

    # Use native curl to get the access token
    try {
        $responseJson = & curl -s -X POST -d $body -H "Content-Type: application/x-www-form-urlencoded" $TokenUrl
        $responseObj = ConvertFrom-Json $responseJson
        $firstFour = $responseObj.access_token.Substring(0, 4)
        $lastEight = $responseObj.access_token.Substring($responseObj.access_token.Length - 8)
        Write-Host "Access Token: $firstFour...$lastEight"
        return $responseObj.access_token
    } catch {
        Write-Error "Failed to retrieve access token: $($_.Exception.Message)"
        return $null
    }
}


function Upload-Package {
    param (
        [string]$UploadUrl,
        [string]$FilePath,
        [string]$Token
    )

    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Use native curl to upload the package, ensure curl is silent to keep output clean
    try {
        $curlCommand = "curl -s -X POST -H `"Authorization: Bearer $Token`" -H `"Accept: application/json`" -F `"file=@`"$FilePath`"`" $UploadUrl"
        $responseJson = & cmd /c $curlCommand
        $responseObj = ConvertFrom-Json -InputObject $responseJson
        Write-Host "Debug: Full Response Object: $(ConvertTo-Json -InputObject $responseObj -Depth 5 -Compress)"
        
        if ($responseObj.value -and $responseObj.value[0].Status -eq 'OK') {
            $packageId = $responseObj.value[0].Body | ConvertFrom-Json | Select-Object -ExpandProperty Id
            $packageVersion = $responseObj.value[0].Body | ConvertFrom-Json | Select-Object -ExpandProperty Version
            Write-Host "Package Uploaded Successfully. Package ID: $packageId, Version: $packageVersion"
            return $true
        } else {
            Write-Host "HTTP Status Code: Not Applicable"
            Write-Host "Response Content: $responseJson"
            throw "Unknown error occurred during upload"
        }
    } catch {
        Write-Error "Failed to upload package: $_"
        Write-Host "Response JSON: $responseJson"
        return $false
    }
}



# Main execution block
$tokenUrl = "https://cloud.uipath.com/identity_/connect/token"
$clientId = $env:UIPATH_CLOUD_CPRIMADOTNET_APP_ID
$clientSecret = $env:UIPATH_CLOUD_CPRIMADOTNET_APP_SECRET
$scope = "OR.Assets OR.BackgroundTasks OR.Execution OR.Folders OR.Jobs OR.Machines.Read OR.Monitoring OR.Robots.Read OR.Settings OR.TestSetExecutions OR.TestSets OR.TestSetSchedules OR.Users.Read"

$token = Get-AccessToken -TokenUrl $tokenUrl -ClientId $clientId -ClientSecret $clientSecret -Scope $scope

if ($token) {
    $uploadUrl = 'https://cloud.uipath.com/cprimadotnet/cprima/orchestrator_/odata/Processes/UiPath.Server.Configuration.OData.UploadPackage'
    $filePath = 'C:\Users\Public\Documents\FrozenChlorine.0.2.3.nupkg'
    $uploadSuccess = Upload-Package -UploadUrl $uploadUrl -FilePath $filePath -Token $token
}
