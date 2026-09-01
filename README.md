# LinuxSecurity

Security tooling for Arch Linux, built in PowerShell. The first tool, Test-ArchPackage, checks a package name against the official Arch repositories and the AUR and returns evidence you can use to judge whether it is safe to install.

## Requirements

PowerShell 7 or later
pacman, included with Arch Linux
yay, an AUR helper, used for AUR lookups
git, used to read PKGBUILD and install script content from the AUR

## Install

Clone this repository and import the module.

```powershell
git clone https://github.com/captainmanny/LinuxSecurity.git
cd LinuxSecurity
Import-Module ./ArchSecurityTools
```

To load it automatically in every session, add the Import-Module line above to your PowerShell profile, `$PROFILE`.

## Usage

Check a single package.

```powershell
Test-ArchPackage -Name 'neovim'
```

Check multiple packages through the pipeline.

```powershell
'neovim', 'powershell-bin' | Test-ArchPackage
```

Run with verbose output to see each lookup step, including network calls to the AUR.

```powershell
Test-ArchPackage -Name 'some-aur-package' -Verbose
```

Full help, including all parameters and examples, is available through the built in help system.

```powershell
Get-Help Test-ArchPackage -Full
```

## What it returns

Test-ArchPackage returns one object per package with these sections.

Source: Official, AUR, or Unknown
Version: the package version reported by pacman or yay
Reputation: AUR maintainer, votes, popularity, and submission dates, for AUR packages only
Upstream: the project URL reported for the package
Integrity: whether checksums are declared for the package sources, and whether any are marked SKIP
PkgbuildBehavior: patterns in the PKGBUILD build script worth a closer look, such as piping a download into a shell or invoking sudo
InstallScript: whether the package has an install script, and the same pattern check applied to it, since install scripts run as root during installation
Recommendation: a Level, one of Routine, Review, High Concern, or Unknown, and a list of Reasons behind it

The Recommendation is not a safety guarantee. It reflects only the evidence the function was able to gather. Read the Reasons and use your own judgment.

## Why this exists

Arch Linux ships most software through its official repositories. Every package there is built by a trusted developer or trusted user, signed with their key, and verified by pacman before installation. That is a real trust chain. You are trusting a small group of vetted maintainers and the signatures pacman checks for you automatically.

The Arch User Repository, the AUR, works differently. Anyone can submit a package. An AUR entry is not a compiled binary sitting in a trusted repository. It is a PKGBUILD, a build script that downloads source code and describes how to turn it into a package on your own machine. Nothing in the AUR is reviewed or signed by Arch. Community votes, comments, and out of date flags exist, but they are optional signals, not gatekeeping.

Installing an AUR package means running someone else's script on your own system, and its install hooks can run as root. This is normal and how AUR helpers like yay work, but it means the burden of review shifts to you.

Test-ArchPackage exists to make that review faster. It automates the evidence gathering: whether a package is official or from the AUR, its community reputation, whether its checksums are present, and whether its build and install scripts contain patterns worth a second look. It does not replace reading the PKGBUILD yourself. It gives you a starting point so you can make an informed decision instead of installing blind.
