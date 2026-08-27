function Get-PacmanInfoValue {
  [CmdletBinding()]
  param(
    [string[]]$InfoLines,
    [string]$Label
  )

  $line = ($InfoLines -match "^$Label")[0]

  if ($line -match "^$Label\s*:\s*(.+)$") {
      $Matches[1].Trim()
    }

}
