param(
  [string]$MaterialPath = (Join-Path $PSScriptRoot "TE material"),
  [string]$OutputPath = (Join-Path $PSScriptRoot "study-material-data.js")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MaterialPath -PathType Container)) {
  throw "Study material folder not found: $MaterialPath"
}

function Get-RelativePath([string]$FullName) {
  return $FullName.Substring($PSScriptRoot.Length).TrimStart('\') -replace '\\', '/'
}

$comingSoonFolderPath = Join-Path $PSScriptRoot "PCB Design\All Lectures"

function New-FolderEntry([System.IO.DirectoryInfo]$Directory, [string]$DisplayName = $Directory.Name) {
  $handwrittenVlsiPath = Join-Path $MaterialPath "VLSI\VLSI  Handwritten"
  if ($Directory.FullName -eq $handwrittenVlsiPath) {
    $DisplayName = "Handwritten VLSI"
  }

  $children = @(
    Get-ChildItem -LiteralPath $Directory.FullName -Force |
      Sort-Object @{ Expression = { if ($_.PSIsContainer) { 0 } else { 1 } } }, Name |
      ForEach-Object {
        if ($_.PSIsContainer) {
          New-FolderEntry $_
        } else {
          [ordered]@{
            name = $_.Name
            type = "file"
            path = Get-RelativePath $_.FullName
          }
        }
      }
  )

  $entry = [ordered]@{
    name = $DisplayName
    type = "folder"
    path = Get-RelativePath $Directory.FullName
    children = $children
  }

  if ($Directory.FullName -eq $comingSoonFolderPath -and $children.Count -eq 0) {
      $entry["comingSoon"] = "Video lectures coming soon."
  }

  return $entry
}

$collections = @(
  [ordered]@{ name = "TE Material (Sem 5)"; path = $MaterialPath },
  [ordered]@{ name = "Deep Researched Projects"; path = (Join-Path $PSScriptRoot "DEEP RESEARCHED PROJECTS") },
  [ordered]@{ name = "PCB Design"; path = (Join-Path $PSScriptRoot "PCB Design") },
  [ordered]@{ name = "Training And Placement"; path = (Join-Path $PSScriptRoot "Training And Placement") }
)

$collectionEntries = @(
  foreach ($collection in $collections) {
    if (-not (Test-Path -LiteralPath $collection.path -PathType Container)) {
      throw "Study material folder not found: $($collection.path)"
    }

    $directory = Get-Item -LiteralPath $collection.path
    New-FolderEntry $directory $collection.name
  }
)

$tree = [ordered]@{
  name = "Study Material"
  type = "folder"
  path = ""
  children = $collectionEntries
}

$json = ConvertTo-Json -InputObject $tree -Depth 100
Set-Content -LiteralPath $OutputPath -Value "window.studyMaterialTree = $json;" -Encoding UTF8
Write-Output "Generated $OutputPath"
