function Get-AurFile {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Name,

    [parameter(Mandatory)]
    [string]$FileName
  )

  $cloneDir = Join-Path ([System.IO.Path]::GetTempPath()) "aur-$Name-$(New-Guid)"

  try {
    $null = git clone --quiet --depth 4 "https://aur.archlinux.org/$Name.git" $cloneDir 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Verbose "Could not clone AUR repo for $Name"
        return $null
      }

      $filePath = Join-Path $cloneDir $FileName
      if (Test-Path $filePath) {
          Get-Content -Path $filePath -Raw 
        }
  }
  finally {
    if (Test-Path $cloneDir) {
        Remove-Item -Path $cloneDir -Recurse -Force
      }
  }

}
