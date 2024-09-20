##########################################################################################
# ###################################################################################### #
# ########## ########## ########## ########## ########## ########## ########## ######### #
# ###################################################################################### #
#                                                                                        #
#   ██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗                            #
#   ██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝                            #
#   ██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║                                 #
#   ██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║                               #
#   ╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╗                            #
#    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝                            #
#                                                                                        #
#   DO NOT MODIFY THIS FILE DIRECTLY.                                                    #
#   This file is automatically updated. Any manual changes will be overwritten.          #
#   Make changes through the Edit-Profile function and save as instructed.               #
#   More details: https://github.com/vkeerthivikram/powershell-profile-vicky.git         #
#                                                                                        #
# ###################################################################################### #
##########################################################################################


# Opt-out of telemetry before doing anything, only if PowerShell is run as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {  # Check if the current user is an admin
    # Set the environment variable to opt-out of PowerShell telemetry
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Test if a connection to GitHub can be established
$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1  # Check connectivity to GitHub with a single ping

# Check if the Terminal-Icons module is not already installed
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    # Install the Terminal-Icons module for the current user, forcing installation and skipping publisher check
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}

# Import the Terminal-Icons module
Import-Module -Name Terminal-Icons

# Define the path to the Chocolatey profile module
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# Check if the Chocolatey profile module exists
if (Test-Path($ChocolateyProfile)) {
    # Import the Chocolatey profile module
    Import-Module "$ChocolateyProfile"
}


# Function to check for updates to the PowerShell profile and apply them if available
function Update-Profile {
    # Check if the global variable canConnectToGitHub is false
    if (-not $global:canConnectToGitHub) {
        # Inform the user that the update check is being skipped due to connectivity issues
        Write-Host "Skipping profile update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return  # Exit the function early if there's no connection
    }

    try {
        # URL of the raw PowerShell profile script to download
        $url = "https://raw.githubusercontent.com/vkeerthivikram/powershell-profile-vicky/main/Microsoft.PowerShell_profile.ps1"
        
        # Get the hash of the current profile to compare later
        $oldhash = Get-FileHash $PROFILE
        
        # Download the latest profile script from the specified URL
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        
        # Get the hash of the newly downloaded profile script
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        
        # Compare the hashes to check if the downloaded file is different from the current profile
        if ($newhash.Hash -ne $oldhash.Hash) {
            # If the hashes are different, copy the new profile to the user's profile location
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            
            # Inform the user that the profile has been updated and prompt for a restart
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        }
    } catch {
        # Handle any errors that occur during the update process
        Write-Error "Unable to check for `$profile updates: $_"
    } finally {
        # Clean up by removing the temporary downloaded profile script
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

Update-Profile  # Call the Update-Profile function to check for and apply any updates to the PowerShell profile

# Function to check for and update PowerShell to the latest version
function Update-PowerShell {
    # Check if the global variable canConnectToGitHub is false
    if (-not $global:canConnectToGitHub) {
        # Inform the user that the update check is being skipped due to connectivity issues
        Write-Host "Skipping PowerShell update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return  # Exit the function early if there's no connection
    }

    try {
        # Inform the user that the update check is starting
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        
        # Initialize a flag to track if an update is needed
        $updateNeeded = $false
        
        # Get the current version of PowerShell
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        
        # URL to access the latest PowerShell release information from GitHub
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        
        # Fetch the latest release information from the GitHub API
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        
        # Extract the latest version number from the release information
        $latestVersion = [Version]($latestReleaseInfo.tag_name.Trim('v'))
        
        # Compare the current version with the latest version to determine if an update is needed
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true  # Set the flag to true if an update is required
        }

        # If an update is needed, proceed with the update process
        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            
            # Use winget to upgrade PowerShell, accepting necessary agreements
            winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
            
            # Inform the user that the update was successful and prompt for a restart
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            # Inform the user that their PowerShell is already up to date
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        # Handle any errors that occur during the update process
        Write-Error "Failed to update PowerShell: $_"
    }
}

Update-PowerShell  # Call the Update-PowerShell function to check for and apply any updates to PowerShell

# Check if the current user is an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)  # Returns true if the user has admin privileges


# Function to customize the PowerShell command prompt
function prompt {
    $location = Get-Location # Get the current location
    $adminSymbol = if ($isAdmin) { "#" } else { "$" } # Determine the admin symbol based on admin status
    "[$location] $adminSymbol " # Return the formatted prompt string

}

# Determine the suffix for the window title based on admin status
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }  # If the user is an admin, append " [ADMIN]" to the title

# Set the PowerShell window title to include the PowerShell version and admin status
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()  # Format the title with the current PowerShell version

# Function to check if a specified command exists in the PowerShell environment
function Test-CommandExists {
    param($command)  # Parameter to accept the command name to check

    # Check if the command exists by attempting to get it, suppressing errors if it doesn't
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)  # Set $exists to true if command is found, false otherwise

    return $exists  # Return the result indicating whether the command exists
}

# Determine the preferred text editor based on available commands
$EDITOR = if (Test-CommandExists code) { 'code' }  # Check if 'code' (Visual Studio Code) is available
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }  # Check if 'sublime_text' (Sublime Text) is available
          elseif (Test-CommandExists notepad++) { 'notepad++' }  # Check if 'notepad++' is available
          elseif (Test-CommandExists notepad) { 'notepad' }  # Check if 'notepad' is available
          elseif (Test-CommandExists nvim) { 'nvim' }  # Check if 'nvim' (Neovim) is available
          elseif (Test-CommandExists pvim) { 'pvim' }  # Check if 'pvim' (PowerVim) is available
          elseif (Test-CommandExists vim) { 'vim' }  # Check if 'vim' (Vim) is available
          elseif (Test-CommandExists vi) { 'vi' } # Check if 'vi' (Vi) is available
          else {'notepad'}   # If no editor is found, default to 'notepad'

# Create an alias 'edit' that points to the preferred text editor stored in the $EDITOR variable
Set-Alias -Name edit -Value $EDITOR  # Set the alias 'edit' to the value of the $EDITOR variable

# Function to open the user's PowerShell profile for editing
function Edit-Profile {
    edit $PROFILE.CurrentUserAllHosts  # Use the 'edit' command to open the profile in the preferred text editor
}

# Function to create a new empty file or update the timestamp of an existing file
function touch($file) { 
    "" | Out-File $file -Encoding ASCII  # Write an empty string to the specified file, creating it if it doesn't exist
}

# Function to search for files matching a specified name pattern in the current directory and subdirectories
function ff($name) {
    # Get all files that match the specified name pattern recursively
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        # Output the full path of each found file
        Write-Output "$($_.FullName)"
    }
}

# Function to retrieve the public IP address of the current machine
function Get-PubIP { 
    # Send a web request to ifconfig.me to get the public IP address and return the content
    (Invoke-WebRequest http://ifconfig.me/ip).Content 
}

Set-Alias -Name pubip -Value Get-PubIP  # Create an alias 'pubip' that points to the 'Get-PubIP' function

# Function to launch a new Windows Terminal instance with administrative privileges
function admin {
    # Check if any arguments were passed to the function
    if ($args.Count -gt 0) {
        # Construct the command string with the provided arguments
        $argList = "& '$args'"
        
        # Start a new Windows Terminal process as an administrator, executing the specified command
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        # Start a new Windows Terminal process as an administrator without any specific command
        Start-Process wt -Verb runAs
    }
}

# Create an alias 'su' that points to the 'admin' function
Set-Alias -Name su -Value admin  # Set the alias 'su' to call the 'admin' function for launching Windows Terminal as an administrator

# Create an alias 'sudo' that also points to the 'admin' function
Set-Alias -Name sudo -Value admin  # Set the alias 'sudo' to call the 'admin' function for launching Windows Terminal as an administrator

# Function to retrieve and display the system's uptime
function uptime {
    # Check if the PowerShell major version is 5
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        # For PowerShell version 5, get the last boot time using WMI
        Get-WmiObject win32_operatingsystem | 
        Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | 
        Format-Table -HideTableHeaders  # Format the output as a table without headers
    } else {
        # For other PowerShell versions, use net statistics to get uptime
        net statistics workstation | 
        Select-String "since" |  # Filter the output to find the line with "since"
        ForEach-Object { $_.ToString().Replace('Statistics since ', '') }  # Remove the prefix to display only the uptime
    }
}

# Function to reload the user's PowerShell profile
function reload-profile {
    & $profile  # Execute the profile script to apply any changes made
}

Set-Alias -Name reload -Value reload-profile  # Create an alias 'reload' that points to the 'reload-profile' function

# Function to extract the contents of a ZIP archive file
function unzip ($file) {
    # Output a message indicating the extraction process
    Write-Output("Extracting", $file, "to", $pwd)  # Inform the user about the extraction location

    # Get the full path of the specified ZIP file in the current directory
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }

    # Extract the contents of the ZIP file to the current directory
    Expand-Archive -Path $fullFile -DestinationPath $pwd  # Use Expand-Archive to unzip the file
}


# Function to search for a specified regular expression pattern in files or input
function grep($regex, $dir) {
    # Check if a directory path was provided
    if ($dir) {
        # Get all files in the specified directory and search for the regex pattern
        Get-ChildItem $dir | Select-String $regex  # Search for the regex in the files of the specified directory
        return  # Exit the function after processing the directory
    }
    
    # If no directory is specified, search the regex in the piped input
    $input | Select-String $regex  # Search for the regex in the input received from the pipeline
}

# Function to display information about the disk volumes on the system
function df {
    get-volume  # Retrieve and display information about all disk volumes
}

# Function to perform a search-and-replace operation on the contents of a specified file
function sed($file, $find, $replace) {
    # Read the content of the specified file, replace occurrences of $find with $replace, and write back to the file
    (Get-Content $file).replace("$find", $replace) | Set-Content $file  # Perform the replacement and save changes
}

# Function to find the full path of a specified command or executable
function which($name) {
    # Retrieve the command information and expand the Definition property to get the full path
    Get-Command $name | Select-Object -ExpandProperty Definition  # Return the full path of the command
}

# Function to create or update an environment variable in the current session
function export($name, $value) {
    # Set the environment variable with the specified name and value, forcing the update if it already exists
    set-item -force -path "env:$name" -value $value;  # Create or update the environment variable
}

# Function to terminate processes by their name
function pkill($name) {
    # Retrieve the process(es) that match the specified name and terminate them
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process  # Stop the process(es) if found
}

# Function to retrieve information about processes by their name
function pgrep($name) {
    # Retrieve and display information about the process(es) that match the specified name
    Get-Process $name  # Return details of the matching process(es)
}

# Function to display the first few lines of a specified file
function head {
    param($Path, $n = 10)  # Define parameters: $Path for the file path, $n for the number of lines to display (default is 10)
    
    # Retrieve and display the first $n lines of the specified file
    Get-Content $Path -Head $n  # Use Get-Content to get the first $n lines of the file
}

# Function to display the last few lines of a specified file, with an option to follow new lines
function tail {
    param(
        $Path,  # The path to the file from which to read
        $n = 10,  # The number of lines to display from the end of the file (default is 10)
        [switch]$f = $false  # A switch to indicate whether to wait for new lines to be added
    )
    
    # Retrieve and display the last $n lines of the specified file, with an option to wait for new lines
    Get-Content $Path -Tail $n -Wait:$f  # Use Get-Content to get the last $n lines, and wait if $f is true
}

# Function to create a new empty file in the current directory
function nf { 
    param($name)  # Define the parameter for the file name
    New-Item -ItemType "file" -Path . -Name $name  # Create a new file with the specified name in the current directory
}

# Function to create a new directory and change the current location to that directory
function mkcd { 
    param($dir)  # Define the parameter for the directory name
    
    mkdir $dir -Force  # Create the new directory with the specified name, forcing creation if it already exists
    Set-Location $dir  # Change the current working directory to the newly created directory
}

# Function to change the current working directory to the user's Documents folder
function docs { 
    Set-Location -Path $HOME\Documents  # Change the current location to the Documents folder
}

# Function to change the current working directory to the user's Desktop folder
function dtop { 
    Set-Location -Path $HOME\Desktop  # Change the current location to the Desktop folder
}

# Function to change the current working directory to the user's Downloads folder
function dload { 
    Set-Location -Path $HOME\Downloads  # Change the current location to the Downloads folder

}

# Function to open the user's PowerShell profile for editing
function ep { 
    edit $PROFILE  # Use the 'edit' command to open the profile in the preferred text editor
}

# Function to terminate a process by its name
function k9 { 
    Stop-Process -Name $args[0]  # Terminate the process that matches the name provided as the first argument
}

# Function to list all items in the current directory, including hidden files, in a formatted table
function la { 
    Get-ChildItem -Path . -Force | Format-Table -AutoSize  # Retrieve items in the current directory and format them as a table
}

# Function to list all items in the current directory, including hidden files, in a formatted table
function ll { 
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize  # Retrieve hidden items in the current directory and format them as a table
}

# Function to check the status of the current Git repository
function gs { 
    git status  # Execute the 'git status' command to display the current state of the repository
}

# Function to add all changes to the current Git repository
function ga { 
    git add .  # Execute the 'git add .' command to add all changes to the repository
}   
# Function to commit changes to the current Git repository with a specified message
function gc {
    param($m)  # Define the parameter for the commit message
    git commit -m "$m"  # Execute the 'git commit -m' command to commit changes with the specified message
}

# Function to push changes to the current Git repository
function gp {
    git push  # Execute the 'git push' command to push changes to the remote repository
}

# Function to pull changes from the current Git repository
function gp {
    git push  # Execute the 'git push' command to push changes to the remote repository
}



# Function to clone a Git repository from a specified URL
function gcl{
    git clone "$args"  # Execute the 'git clone' command to clone a repository from the specified URL
}

# Function to add changes to the Git repository and commit them with a specified message
function gcom {
    git add .  # Stage all changes in the current directory for the next commit
    git commit -m "$args"  # Commit the staged changes with the provided commit message
}

# Function to add changes to the Git repository, commit them with a specified message, and push to the remote repository
function lazyg {
    git add .  # Stage all changes in the current directory for the next commit
    git commit -m "$args"  # Commit the staged changes with the provided commit message
    git push  # Push the committed changes to the remote repository
}

# Function to retrieve and display detailed information about the computer's hardware and operating system
function sysinfo { 
    Get-ComputerInfo  # Execute the cmdlet to get and display system information
}

# Function to clear the DNS client cache
function flushdns {
    Clear-DnsClientCache  # Clear the DNS resolver cache to remove all cached entries
    Write-Host "DNS has been flushed"  # Inform the user that the DNS cache has been cleared
}

# Function to copy a specified string to the clipboard
function cpy { 
    Set-Clipboard $args[0]  # Copy the first argument provided to the function to the clipboard
}

# Function to retrieve and display the current content of the clipboard
function pst { 
    Get-Clipboard  # Retrieve and output the content of the clipboard
}

# Set the color options for the PowerShell ReadLine interface
Set-PSReadLineOption -Colors @{
    Command = 'Yellow'  # Set the color for commands to Yellow
    Parameter = 'Green'  # Set the color for parameters to Green
    String = 'DarkCyan'  # Set the color for strings to DarkCyan
}

# Define additional options for the PowerShell ReadLine interface
$PSROptions = @{
    ContinuationPrompt = '  '  # Set the continuation prompt to two spaces
    Colors = @{
        Parameter = $PSStyle.Foreground.Magenta  # Set the color for parameters to Magenta
        Selection = $PSStyle.Background.Black  # Set the background color for selection to Black
        InLinePrediction = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack  # Set the color for inline predictions
    }
}

# Apply the defined options to the PowerShell ReadLine interface
Set-PSReadLineOption @PSROptions

# Set key handlers for specific keyboard shortcuts
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord  # Bind Ctrl+f to move the cursor forward by one word
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine  # Bind Enter to validate and accept the current line


# Define a script block for argument completion for the 'dotnet' command
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)  # Define parameters for the script block: the word to complete, the command AST, and the cursor position
    
    # Call the 'dotnet complete' command to get completion suggestions based on the current cursor position and command
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            # Create a new CompletionResult for each suggestion returned by the 'dotnet complete' command
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# Register the argument completer for the 'dotnet' command using the defined script block
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock



# Function to set the theme for the PowerShell prompt using Oh My Posh
function Get-Theme {
    $themePattern = 'oh-my-posh init pwsh --config "\$env:POSH_THEMES_PATH/dracula.omp.json" | Invoke-Expression' # Set the theme pattern to the Dracula theme
    if (Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType Leaf) {  # Check if the profile file exists
        $existingTheme = Select-String -Raw -Path $PROFILE.CurrentUserAllHosts -Pattern $themePattern  # Search for the theme pattern in the profile file

        if ($null -ne $existingTheme) {
            Invoke-Expression $existingTheme  # Execute the theme if found
            return
        }
    }
    oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json | Invoke-Expression  # Initialize Oh My Posh with the Dracula theme
}

Get-Theme # Apply the theme to the PowerShell prompt


# Check if the 'zoxide' command is available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # If 'zoxide' is found, initialize it with the command to change directory to PowerShell
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
} else {
    # If 'zoxide' is not found, inform the user and attempt to install it via winget
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        # Use winget to install zoxide with the specified ID
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        
        # After installation, initialize zoxide for PowerShell
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        # Handle any errors that occur during the installation process
        Write-Error "Failed to install zoxide. Error: $_"
    }
}

# Set aliases for zoxide commands
Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force


# Add a Show-Help function
function Show-Help {
    Write-Host "Available custom commands:"
    Write-Host "  Update-Profile    - Check for and apply updates to the PowerShell profile"
    Write-Host "  Update-PowerShell - Check for and update PowerShell to the latest version"
    Write-Host "  Edit-Profile      - Open the PowerShell profile for editing"
    Write-Host "  reload            - Reload the PowerShell profile"
    Write-Host "  unzip             - Extract contents of a ZIP file"
    Write-Host "  grep              - Search for a pattern in files or input"
    Write-Host "  sed               - Perform search-and-replace on file contents"
    Write-Host "  which             - Find the full path of a command"
    Write-Host "  export            - Set an environment variable"
    Write-Host "  pkill             - Terminate processes by name"
    Write-Host "  pgrep             - Get information about processes by name"
    Write-Host "  head              - Display the first few lines of a file"
    Write-Host "  tail              - Display the last few lines of a file"
    Write-Host "  nf                - Create a new empty file"
    Write-Host "  mkcd              - Create a new directory and change to it"
    Write-Host "  docs, dtop, dload - Change to Documents, Desktop, or Downloads folder"
    Write-Host "  la, ll            - List directory contents (including hidden files)"
    Write-Host "  gs, ga, gc, gp    - Git status, add, commit, and push shortcuts"
    Write-Host "  gcl, gcom, lazyg  - Git clone, commit, and lazy git (add, commit, push)"
    Write-Host "  sysinfo           - Display system information"
    Write-Host "  flushdns          - Clear the DNS client cache"
    Write-Host "  cpy, pst          - Copy to and paste from clipboard"
}

# Display a message to the user when the profile is loaded
Write-Host "Use 'Show-Help' to display help"



