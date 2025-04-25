
# Define a parameter block to allow users to specify the directory path
param (
    [string]$DirectoryPath = (Get-Location).Path
)


function Parse-SemVer {
    param (
        [string]$semVerString
    )

    # regex pattern with case-insensitive flag (?i)
    $pattern = '(?i)^' +
    '(0|[1-9]\d*)\.' + # Major
    '(0|[1-9]\d*)\.' + # Minor
    '(0|[1-9]\d*)' + # Patch
    '(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*))*))?' + # Pre-release
    '(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'  # Build

    # match is case-insensitive
    if ($semVerString -match $pattern) {
        $result = @{
            Major      = $Matches[1]
            Minor      = $Matches[2]
            Patch      = $Matches[3]
            PreRelease = $Matches[4]
            Build      = $Matches[5]
        }

        return $result
    }
    else {
        throw 'Invalid SemVer string'
    }
}

function Increment-SemVer {
    param (
        [string]$semVerString,
        [string]$commitMessage
    )

    # Parse the existing SemVer string
    $parsedVersion = Parse-SemVer -semVerString $semVerString

    if ($commitMessage -match 'BREAKING|BREAKING CHANGE|major') {
        # Major version increment
        $parsedVersion.Major = [int]$parsedVersion.Major + 1
        $parsedVersion.Minor = 0
        $parsedVersion.Patch = 0
        $parsedVersion.PreRelease = $null
    }
    elseif ($commitMessage -match 'feat|feature|minor') {
        # Minor version increment
        $parsedVersion.Minor = [int]$parsedVersion.Minor + 1
        $parsedVersion.Patch = 0
        $parsedVersion.PreRelease = $null
    }
    elseif ($parsedVersion.PreRelease -and $commitMessage -notmatch 'fix|bugfix|patch|feat|feature|minor|BREAKING|BREAKING CHANGE|major') {
        # Increment pre-release version for non-specific commit messages
        if ($parsedVersion.PreRelease -match '(\d+)$') {
            $numeral = [int]$matches[1] + 1
            $parsedVersion.PreRelease = $parsedVersion.PreRelease -replace '(\d+)$', $numeral
        }
        else {
            $parsedVersion.PreRelease += '.1'
        }
    }
    elseif ($commitMessage -match 'fix|bugfix|patch') {
        # Patch version increment
        $parsedVersion.Patch = [int]$parsedVersion.Patch + 1
        $parsedVersion.PreRelease = $null
    }
    else {
        # Default case: increment the Patch version
        $parsedVersion.Patch = [int]$parsedVersion.Patch + 1
    }

    # Build metadata is left unchanged

    # Construct updated version string
    $updatedVersion = "{0}.{1}.{2}" -f $parsedVersion.Major, $parsedVersion.Minor, $parsedVersion.Patch
    if ($parsedVersion.PreRelease) {
        $updatedVersion += "-$($parsedVersion.PreRelease)"
    }
    if ($parsedVersion.Build) {
        $updatedVersion += "+$($parsedVersion.Build)"
    }

    return $updatedVersion
}






# Define the version number of the package to be downloaded.
$version = "23.6.8581.19168"

# Specify the directory where the downloaded package will be extracted.
$extractPath = "C:\Users\Public\uipcli"

# Set the package name for which the NuGet package will be downloaded.
$packageName = "UiPath.CLI.Windows"

# Construct the URL to download the NuGet package using the specified version and package name.
$packageUrl = "https://uipath.pkgs.visualstudio.com/Public.Feeds/_packaging/UiPath-Official/nuget/v3/flat2/$packageName/$version/$packageName.$version.nupkg"

# Generate a temporary path to store the downloaded NuGet package.
$tempPath = [System.IO.Path]::GetTempPath() + "$packageName.$version.nupkg"

# Create a temporary path for converting the NuGet package to a ZIP file for extraction.
$tempZipPath = [System.IO.Path]::GetTempPath() + "$packageName.$version.zip"

# Download the NuGet package from the specified URL to the temporary path.
Invoke-WebRequest -Uri $packageUrl -OutFile $tempPath

# Rename the downloaded NuGet package to a ZIP file to prepare for extraction.
Rename-Item -Path $tempPath -NewName $tempZipPath

# Extract the ZIP file to the designated extraction path, overwriting files if they exist.
Expand-Archive -Path $tempZipPath -DestinationPath $extractPath -Force

# Remove the temporary ZIP file after extraction to clean up the temporary files.
Remove-Item $tempZipPath





Push-Location $DirectoryPath

# Load the project.json file as a JSON object from the specified or default directory
$projectJsonPath = Join-Path -Path $DirectoryPath -ChildPath "project.json"
$projectJson = Get-Content $projectJsonPath -Raw | ConvertFrom-Json

# Retrieve the latest commit message from the git log
$commitMessage = (git log --format=%B -n 1) -join " "

# Increment the Semantic Version based on the latest commit message
$incrementedVersion = Increment-SemVer -semVerString $projectJson.projectVersion -commitMessage $commitMessage

# Update the projectVersion in the JSON object
$projectJson.projectVersion = $incrementedVersion

# Convert the JSON object back to a JSON formatted string and save it to the project.json file in the specified or default directory
$projectJson | ConvertTo-Json -Depth 99 | Set-Content $projectJsonPath

# Stage the modified project.json for commit, suppressing e.g. untracked file output
git add $projectJsonPath *>$null

# Commit the version update to the repository with a message noting the new version number
git commit -m "Version bump in project.json to new version $incrementedVersion" --quiet

# Push the commit to the remote repository
# Uncomment if you really want this script to push
#git push

Pop-Location









# Execute the UiPath CLI tool to package the project located at projectJsonPath.
# This command packs the project into a format specified by the project's design options,
# outputs to a specified directory, sets verbosity for detailed logging, and disables telemetry for privacy.
& "$extractPath\tools\uipcli.exe" package pack $projectJsonPath --output "C:\Users\Public\Documents\" --traceLevel Verbose --disableTelemetry --outputType $projectJson.designOptions.outputType




function Import-Env {
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('dotenv')]
    param(
        [ValidateNotNullOrEmpty()]
        [String] $Path = '.env',

        # Determines whether variables are environment variables or normal
        [ValidateSet('Environment', 'Regular')]
        [String] $Type = 'Environment'
    )
    $Env = Get-Content -raw $Path | ConvertFrom-StringData
    $Env.GetEnumerator() | Foreach-Object {
        $Name, $Value  = $_.Name, $_.Value
        
        # Account for quote rules in Bash
        $StartQuote = [Regex]::Match($Value, "^('|`")")
        $EndQuote = [Regex]::Match($Value, "('|`")$")
        if ($StartQuote.Success -and -not $EndQuote.Success) {
            throw [System.IO.InvalidDataException] "Missing terminating quote $($StartQuote.Value) in '$Name': $Value"
        } elseif (-not $StartQuote.Success -and $EndQuote.Success) {
            throw [System.IO.InvalidDataException] "Missing starting quote $($EndQuote.Value) in '$Name': $Value"
        } elseif ($StartQuote.Value -ne $EndQuote.Value) {
            throw [System.IO.InvalidDataException] "Mismatched quotes in '$Name': $Value"
        } elseif ($StartQuote.Success -and $EndQuote.Success) {
            $Value = $Value -replace "^('|`")" -replace "('|`")$"  # Trim quotes
        }
        
        if ($PSCmdlet.ShouldProcess($Name, "Importing $Type Variable")) {
            switch ($Type) {
                'Environment' { Set-Content -Path "env:\$Name" -Value $Value }
                'Regular' { Set-Variable -Name $Name -Value $Value -Scope Script }
            }
        }
    }
}

Import-Env Join-Path -Path $env:USERPROFILE -ChildPath ".env"