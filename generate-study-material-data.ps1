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

function New-FolderEntry([System.IO.DirectoryInfo]$Directory) {
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

  return [ordered]@{
    name = $Directory.Name
    type = "folder"
    path = Get-RelativePath $Directory.FullName
    children = $children
  }
}

$materialDirectory = Get-Item -LiteralPath $MaterialPath
$tree = [ordered]@{
  name = "Study Material"
  type = "folder"
  path = ""
  children = @(
    [ordered]@{
      name = "TE Material"
      type = "folder"
      path = Get-RelativePath $materialDirectory.FullName
      children = (New-FolderEntry $materialDirectory).children
      comingSoonSubjects = @("BM", "Agentic AI")
    }
  )
}

$json = ConvertTo-Json -InputObject $tree -Depth 100
Set-Content -LiteralPath $OutputPath -Value "window.studyMaterialTree = $json;" -Encoding UTF8
Write-Output "Generated $OutputPath"
