function Get-PackageRecommendation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [pscustomobject]$Reputation,
        [pscustomobject]$Integrity,
        [pscustomobject]$PkgbuildBehavior,
        [pscustomobject]$InstallScript
    )

    if ($Source -eq 'Unknown') {
        return [pscustomobject]@{
            Level   = 'Unknown'
            Reasons = @('Package was not found in the official repositories or the AUR.')
        }
    }

    if ($Source -eq 'Official') {
        return [pscustomobject]@{
            Level   = 'Routine'
            Reasons = @('Distributed through the official Arch repositories.')
        }
    }

    $highConcern = [System.Collections.Generic.List[string]]::new()
    $review      = [System.Collections.Generic.List[string]]::new()

    if ($PkgbuildBehavior -and $PkgbuildBehavior.Findings.Count -gt 0) {
        $highConcern.Add("PKGBUILD build script: $($PkgbuildBehavior.Findings -join '; ')")
    }

    if ($InstallScript -and $InstallScript.Findings.Count -gt 0) {
        $highConcern.Add("Install script (runs as root during install): $($InstallScript.Findings -join '; ')")
    }

    if ($Integrity -and $Integrity.HasSkippedChecksums) {
        $highConcern.Add('One or more source checksums are marked SKIP (downloads are not verified).')
    }

    if ($Reputation) {
        if ($Reputation.IsOutOfDate) {
            $review.Add('Flagged out-of-date on AUR.')
        }

        if (-not $Reputation.Maintainer) {
            $review.Add('Package is orphaned (no maintainer).')
        }

        $votes = $Reputation.Votes -as [int]
        if ($null -ne $votes -and $votes -lt 5) {
            $review.Add("Very few AUR votes ($votes) - limited community visibility.")
        }
    }

    if ($Integrity -and -not $Integrity.HasChecksums) {
        $review.Add("No checksums declared for this package's sources.")
    }

    if ($highConcern.Count -gt 0) {
        return [pscustomobject]@{ Level = 'High Concern'; Reasons = @($highConcern) }
    }

    if ($review.Count -gt 0) {
        return [pscustomobject]@{ Level = 'Review'; Reasons = @($review) }
    }

    [pscustomobject]@{
        Level   = 'Routine'
        Reasons = @('No suspicious signals found in the available evidence.')
    }
}
