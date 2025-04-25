# Set the Identity Server token endpoint
$tokenUrl = "https://cloud.uipath.com/identity_/connect/token"

# Retrieve client credentials from environment variables
$clientId = $env:UIPATH_CLOUD_CPRIMADOTNET_APP_ID
$clientSecret = $env:UIPATH_CLOUD_CPRIMADOTNET_APP_SECRET

# Log the client ID and client secret to verify correctness
Write-Host "Client ID: $clientId"
Write-Host "Client Secret: ***"

# Define the scopes your application needs; adjust this according to your actual requirements
$scope = "OR.Assets OR.Execution OR.Folders OR.Jobs OR.Machines.Read OR.Monitoring OR.Robots.Read OR.Settings OR.Users.Read OR.BackgroundTasks OR.TestSetExecutions OR.TestSets OR.TestSetSchedules"

# Prepare the body of the request
$body = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    scope = $scope
}

# Convert body to x-www-form-urlencoded content
$bodyArray = $body.GetEnumerator() | ForEach-Object {
    "{0}={1}" -f [System.Web.HttpUtility]::UrlEncode($_.Key), [System.Web.HttpUtility]::UrlEncode($_.Value)
}
$bodyString = $bodyArray -join "&"

# Print debug information for the request body
Write-Host "Request Body for Debug:"
Write-Host $bodyString

# Set additional headers
$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}

# Send the POST request to get the token
try {
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $bodyString -Headers $headers
    Write-Host "Access Token: $($response.access_token)"

    # Define the endpoint for package upload
    $uploadUrl = 'https://cloud.uipath.com/cprimadotnet/cprima/orchestrator_/odata/Processes/UiPath.Server.Configuration.OData.UploadPackage'
    $filePath = 'C:\Users\Public\Documents\FrozenChlorine.0.2.3.nupkg'
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $fileEnc = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($fileBytes)

    # Prepare headers for the upload request
    $uploadHeaders = @{
        "accept" = "application/json"
        "authorization" = "Bearer $($response.access_token)"
        "Content-Type" = "multipart/form-data"
    }

    # Construct the body for the upload request
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = (
        "--$boundary",
        'Content-Disposition: form-data; name="file"; filename="FrozenChlorine.0.2.3.nupkg"',
        "Content-Type: application/octet-stream$LF",
        $fileEnc,
        "--$boundary--$LF"
    ) -join $LF

    $uploadHeaders["Content-Type"] = "multipart/form-data; boundary=$boundary"

    # Send the upload request
    $uploadResponse = Invoke-RestMethod -Uri $uploadUrl -Method Post -ContentType $uploadHeaders["Content-Type"] -Headers $uploadHeaders -Body $bodyLines
    Write-Host "Package Uploaded Successfully: $($uploadResponse)"
} catch {
    Write-Host "Error making API call:"
    Write-Host "HTTP Status Code: $($_.Exception.Response.StatusCode.Value__)"
    Write-Host "HTTP Status Description: $($_.Exception.Response.ReasonPhrase)"
    try {
        $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
        Write-Host "Response Content: $responseContent"
    } catch {
        Write-Host "Failed to read response content."
    }
}



