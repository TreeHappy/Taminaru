param (
  [Parameter(Mandatory=$true)]
  [string]$PackagesFile
)

Import-Module -Name $PSScriptRoot/winget.psm1 -Force

function UpdateAllPakages($packages)
{
  foreach ($package in $packages)
  {
    Write-Output "Checking update for $($package.PackageIdentifier)"

    gum spin --spinner moon --title "Checking ..." -- winget upgrade --id $package.PackageIdentifier --accept-source-agreements --silent | Out-Null

    if ($?)
    {
      Write-Output "  $($package.PackageIdentifier) has updates available."
    } else
    {
      Write-Output "  $($package.PackageIdentifier) is up to date."
    }
  }
}

UpdateAllPakages(ListPackages(GetJsonObject($PackagesFile)))

