# Check if the current user is not in the Administrator role
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Display a warning message if the script is not run as Administrator
    Write-Warning "Please run this script as an Administrator!"
    # Stop the execution of the script
    break
}

# Function to test internet connectivity by pinging a specified host
function Test-InternetConnection {
    try {
        # Attempt to ping the specified computer (Google in this case)
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true  # Return true if the ping is successful
    }
    catch {
        # Warning message if the internet connection is not available
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false  # Return false if the ping fails
    }
}

# Function to install Nerd Fonts on the system
function Install-NerdFonts {
    param (
        [string]$FontName = "JetBrainsMono",  # Default font name for JetBrains Mono
        [string]$FontDisplayName = "JetBrains Mono"  # Display name for the font
    )

    try {
        # Load the System.Drawing assembly for font operations
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        
        # Get the list of installed font families
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        # Check if the specified font is already installed
        if ($fontFamilies -notcontains "${FontDisplayName}") {
            # Fetch the latest version from GitHub releases
            $latestRelease = (Invoke-RestMethod -Uri "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest").tag_name
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/${latestRelease}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"  # Path to download the zip file
            $extractPath = "$env:TEMP\${FontName}"  # Path to extract the zip file

            # Create a web client to download the font zip file
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($fontZipUrl)), $zipFilePath)  # Start downloading

            # Wait for the download to complete
            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2  # Sleep for 2 seconds
            }

            # Extract the downloaded zip file to the specified path
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            
            # Get the Shell.Application COM object to copy files
            $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            
            # Loop through each .ttf file in the extracted folder
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                # Check if the font is not already in the Fonts directory
                If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    # Copy the font file to the Windows Fonts directory
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            # Clean up by removing the extracted files and the zip file
            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
        } else {
            # Inform the user that the font is already installed
            Write-Host "Font ${FontDisplayName} already installed"
        }
    }
    catch {
        # Handle any errors that occur during the process
        Write-Error "Failed to download or install ${FontDisplayName} font. Error: $_"
    }
}

# Function to install packages using winget
function Install-WingetPackage {
    param (
        [string]$PackageId,
        [string]$PackageName
    )

    try {
        # Check if the package is already installed
        if (-not (winget list --id $PackageId -e)) {
            Write-Verbose "Installing $PackageName..."
            winget install -e --id $PackageId --accept-source-agreements --accept-package-agreements
            Write-Host "$PackageName installed successfully."
        } else {
            Write-Host "$PackageName is already installed."
        }
    } catch {
        Write-Error "Failed to install $PackageName. Error: $_"
    }
}

# Function to install PowerShell modules
function Install-PSModule {
    param (
        [string]$ModuleName
    )

    try {
        if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Verbose "Installing $ModuleName module..."
            Install-Module -Name $ModuleName -Repository PSGallery -Force -ErrorAction Stop
            Write-Host "$ModuleName module installed successfully."
        } else {
            Write-Host "$ModuleName module is already installed."
        }
    } catch {
        Write-Error "Failed to install $ModuleName module. Error: $_"
    }
}

# Main installation process
try {
    # Check if the internet connection is available
    if (-not (Test-InternetConnection)) {
        # If the internet connection is not available, stop the script execution
        break
    }

    # Check if the PowerShell profile does not exist
    if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
        try {
            # Detect the version of PowerShell and create profile directories if they do not exist
            $profilePath = ""  # Initialize the profile path variable
            if ($PSVersionTable.PSEdition -eq "Core") {
                # Set profile path for PowerShell Core
                $profilePath = "$env:userprofile\Documents\Powershell"
            }
            elseif ($PSVersionTable.PSEdition -eq "Desktop") {
                # Set profile path for Windows PowerShell Desktop
                $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
            }

            # Check if the profile path directory does not exist
            if (!(Test-Path -Path $profilePath)) {
                # Create the profile directory
                New-Item -Path $profilePath -ItemType "directory"
            }

            # Download the PowerShell profile script from the specified URL
            Invoke-RestMethod https://github.com/vkeerthivikram/powershell-profile-vicky/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
            Write-Host "The profile @ [$PROFILE] has been created."  # Inform the user of the profile creation
            Write-Host "If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
        }
        catch {
            # Handle any errors that occur during the profile creation or update process
            Write-Error "Failed to create or update the profile. Error: $_"
        }
    }
    else {
        try {
            # If the profile already exists, back it up by moving it to a new file
            Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
            # Download a new PowerShell profile script from a different URL
            Invoke-RestMethod https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
            Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
            Write-Host "Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
        }
        catch {
            # Handle any errors that occur during the backup and update process
            Write-Error "Failed to backup and update the profile. Error: $_"
        }
    }
    # PowerShell Core represents a significant evolution of PowerShell, focusing on cross-platform 
    # capabilities and modern development practices, while PowerShell Desktop remains a stable, Windows-only 
    # environment primarily for legacy support. 
    # This shift allows users to leverage PowerShell in diverse environments, enhancing automation and 
    # scripting across different operating systems.

    # Set execution policy and install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Install packages using winget
    Install-WingetPackage -PackageId "JanDeDobbeleer.OhMyPosh" -PackageName "Oh My Posh"
    Install-WingetPackage -PackageId "ajeetdsouza.zoxide" -PackageName "zoxide"

    # Install PowerShell modules
    Install-PSModule -ModuleName "Terminal-Icons"

    # Install Nerd Fonts
    Install-NerdFonts -FontName "JetBrainsMono" -FontDisplayName "JetBrains Mono"

    # Final check
    if ((Test-Path -Path $PROFILE) -and (winget list --id "JanDeDobbeleer.OhMyPosh" -e) -and ($fontFamilies -contains "JetBrains Mono")) {
        Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
    } else {
        Write-Warning "Setup completed with some issues. Please check the messages above for details."
    }
} catch {
    Write-Error "An error occurred during the setup process: $_"
}
