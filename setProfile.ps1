# Get the path to the current user's PowerShell profile
$profilePath = Split-Path -Path $PROFILE

# Copy the Microsoft.PowerShell_profile.ps1 file to the user's profile directory
Copy-Item .\Microsoft.PowerShell_profile.ps1 $profilePath