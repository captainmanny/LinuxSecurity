function Get-AurPkgbuild {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Name
  )
  
  $cloneDir = Join-Path ([System.IO.Path]::GetTempPath()) "aur-$Name-$(New-Guid)"

  try {
      $null = git clone --quiet --depth 1 "https://aur.archlinux.org/$Name.git" $cloneDir 2>$null
      if ($LASTEXITCODE -ne 0) {
          Write-Verbose "Could not clone AUR repo fo $Name"
          return $null
        }

        Get-Content -Path (Join-Path $cloneDir 'PKGBUILD') -Raw
    } finally {
        if (Test-Path $cloneDir) {
            Remove-Item -Path $cloneDir -Recurse -Force
          }
      }

}
