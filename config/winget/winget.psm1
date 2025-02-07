function GetJsonObject([string]$fileLocation)
{
  $packagesJson = Get-Content -Raw -Path "$fileLocation" | ConvertFrom-Json

  $packagesJson
}

function ListPackages($jsonObject)
{
  $packages = $jsonObject.Sources.Packages

  $packages
}
