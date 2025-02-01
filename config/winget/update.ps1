param (
  [Parameter(Mandatory=$true)]
  [string]$PackagesFile
)

function ListPackages([string]$fileLocation)
{
  # Load the exported packages
  $packagesJson = Get-Content -Raw -Path "$PackagesFile" | ConvertFrom-Json

  $packagesJson
}

function UpdateAllPakages($packages)
{
  # Check for updates for each package
  foreach ($package in $packages)
  {
    Write-Output "Checking update for $($package.PackageIdentifier)"

    winget upgrade --id $package.PackageIdentifier --accept-source-agreements --silent | Out-Null

    if ($?)
    {
      Write-Output "$packageName has updates available."
    } else
    {
      Write-Output "$packageName is up to date."
    }
  }
}

$packagesJson = ListPackages $PackagesFile
$packages = $packagesJson.Sources.Packages

UpdateAllPakages($packages)
