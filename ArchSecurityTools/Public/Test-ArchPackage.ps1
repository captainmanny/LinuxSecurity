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

  # GETTING REPUTATION LOGIC
  $reputation = if ($isAur) {
      [PSCustomObject]@{
        Maintainer = Get-PacmanInfoValue -InfoLines $aurLines -Label 'Maintainer'
        Votes = Get-PacmanInfoValue -InfoLines $aurLines -Label 'Votes'
        Popularity = Get-PacmanInfoValue -InfoLines $aurLines -Label 'Popularity'
        FirstSubmitted = Get-PacmanInfoValue -InfoLines $aurLines -Label 'First Submitted'
        LastModified = Get-PacmanInfoValue -InfoLines $aurLines -Label 'Last Modified'
      }
    }
    else {
        $null
      }

  # GETTING UPSTREAM URL 
  $upstream = [PSCustomObject]@{
    URL = switch ($true) {
        $isOfficial { Get-PacmanInfoValue -InfoLines $officialLines -Label 'URL'}
        $isAur { Get-PacmanInfoValue -InfoLines $aurLines -Label 'URL '}
        $default { $null }
      } 
  }

  # GETTING PACKAGE  
  $pkgbuild = if ($isAur) {
    Write-Verbose "Fetching PKGBUILD for $Name for AUR"
    Get-AurPkgbuild -Name $Name    
  }
  else {
      $null
    }

  # GETTING HASHES
  $integrity = if ($pkgbuild) {
      [PSCustomObject]@{
        HasCheckSums = $pkgbuild -match 'sums(_\w+)?=\('
        HasSkippedCheckSums = $pkgbuild -match 'sums(_\w+)?=\([^)]*SKIP'
      }
    }
    else {
        $null
      }
  # DEFINING suspiciousPatterns
  $suspiciousPatterns = @{
    'Pipes download file into shell' = '(curl|wget)[^\n]*\|\s*(sh|bash)'
    'Invokes sudo inside the build script' = '\bsudo\b'
    }    

# CHECK BEHAVIOR
  $behavior = if ($pkgbuild) {
     $findings = foreach ($description in $suspiciousPatterns.Keys) {
        if ($pkgbuild -match $suspiciousPatterns[$description]){
            $description
          }
      }

      [PSCustomObject]@{
        Findings = @($findings)
      }
  }
  else {
      $null
    }

# INSTALL SCRIPT DETECTION 
  
  $installScriptName = if ($pkgbuild -match 'install\s*=\s*[''"]?([^\s''"]+)') { $Matches[1] }

  $installScript = if ($installScriptName) {
      Write-Verbose "Fetching install script '$installScriptName' for $Name"
      Get-AurFile -Name $Name -FileName $installScriptName
    }
    else {
        $null
      }

$installScriptInfo = [pscustomobject]@{
        HasInstallScript = [bool]$installScriptName
        FileName         = $installScriptName
        Findings         = if ($installScript) {
            @(foreach ($description in $suspiciousPatterns.Keys) {
                if ($installScript -match $suspiciousPatterns[$description]) {
                    $description
                }
            })
        } else {
            @()
        }
    }

# GET RECOMMENDATIONS
$params = @{
    Source = $source
    Reputation = $reputation
    Integrity = $integrity
    PkgbuildBehavior = $behavior
    installScript = $installScriptInfo
  }

$recommendation = Get-PackageRecommendation @params

# CREATING CUSTOM OBJECT 
[PSCustomObject]@{
  Name = $Name
  Source = $source
  Version = $version
  Reputation = $reputation
  Upstream = $upstream
  Integrity = $integrity
  PkgbuildBehavior = $behavior
  InstallScript = $installScriptInfo
  Recommendation = $recommendation
}

} 
