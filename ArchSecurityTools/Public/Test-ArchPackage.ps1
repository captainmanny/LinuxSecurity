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
  $aurLines = yay -Si --aur $Name 2>$null
  $isAur = $LASTEXITCODE -eq 0

  # SETTING SWITCH STATEMENT

  $source = switch ($true) {
      $isOfficial { 'Official'}
      $isAur      { 'AUR'}
      default     { 'Unknown'}
    }
  
  $version = switch ($true) {
      $isOfficial { Get-PacmanInfoValue -InfoLines $officialLines -Label 'Version'}
      $isAur { Get-PacmanInfoValue -InfoLines $aurLines -Label 'Version'}
      default { $null }
    }

[PSCustomObject]@{
  Name = $Name
  Source = $source
  Version = $version
}

} 
