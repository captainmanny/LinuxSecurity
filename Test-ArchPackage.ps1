function Test-ArchPackage {
  [CmdletBinding()]
  param (
   [Parameter(Mandatory)]
   [string]$Name
  )
  
   Write-Verbose "Checking package: $Name" 

  $null = pacman -Si $Name 2>$null
  $isOfficial = $LASTEXITCODE -eq 0

  [PSCustomObject]@{
    Name = $Name
    IsOfficial = $isOfficial
  }

} 
