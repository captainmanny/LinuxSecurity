function Test-ArchPackage {
  [CmdletBinding()]
  param (
   [Parameter(Mandatory)]
   [string]$Name
  )

   Write-Verbose "Checking package: $Name"

  # CHECKING OFFICAL SYNC DATABASES
  $officialLines = pacman -Si $Name 2>$null
  $isOfficial = $LASTEXITCODE -eq 0
  
  # CHECKING AUR
  $null = yay -Si --aur $Name 2>$null
  $isAur = $LASTEXITCODE -eq 0

  # SETTING SWITCH STATEMENT

  $source = switch ($true) {
      $isOfficial { 'Official'}
      $isAur      { 'AUR'}
      default     { 'Unknown'}
    }
  
  $version = $null
  if ($isOfficial) {
      $versionLine = ($officialLines -match '^Version')[0]
      if ($versionLine -match '^Version\s*:\s*(.+)$') {
          $version = $Matches[1].Trim()
        }

    }
  [PSCustomObject]@{
    Name = $Name
    Source = $source
    Version = $version
  }

} 
