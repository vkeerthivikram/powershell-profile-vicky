# 🌟 My PowerShell Profile

This repository contains my customized PowerShell profile script, which enhances the functionality and user experience of the PowerShell terminal. The profile includes various functions, aliases, and settings to streamline and improve productivity.

## ✨ Inspiration

I have taken heavy inspiration and code from [Chris Titus Tech's PowerShell Profile](https://github.com/ChrisTitusTech/powershell-profile). His work has been instrumental in shaping my own PowerShell profile, and I highly recommend checking out his repository for more advanced and detailed configurations.

## 🚀 Features

- **Custom Prompt**: A customized prompt that displays the current directory and admin status.
- **Docker Commands**: Functions for common Docker Compose commands (`up`, `down`, `build`, `logs`, `restart`, `ps`, `exec`, `pull`).
- **Profile Update**: Functions to check for and apply updates to the PowerShell profile.
- **PowerShell Update**: Functions to check for and update PowerShell to the latest version.
- **Theme Management**: Functions to set and manage themes using Oh My Posh.
- **Aliases**: Convenient aliases for common commands and functions.
- **Help Function**: A `Show-Help` function to display available custom commands.

## 📥 Installation

To use this PowerShell profile, follow these steps:

1. **Clone this repository to your local machine:**
    ```pwsh
    git clone https://github.com/vkeerthivikram/powershell-profile-vicky.git
    ```

2. **Copy the `Microsoft.PowerShell_profile.ps1` file to your PowerShell profile directory:**
    ```pwsh
    cp powershell-profile-vicky/Microsoft.PowerShell_profile.ps1 $PROFILE
    ```

3. **Restart your PowerShell terminal to apply the changes:**
    ```pwsh
    restart-shell
    ```

## ⚡ One Line Install (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```pwsh
irm "https://github.com/vkeerthivikram/powershell-profile-vicky/raw/main/setup.ps1" | iex
```

## 🛠️ Usage

### Custom Commands

- **Update-Profile**: Check for and apply updates to the PowerShell profile.
- **Update-PowerShell**: Check for and update PowerShell to the latest version.
- **Edit-Profile**: Open the PowerShell profile for editing.
- **reload**: Reload the PowerShell profile.
- **unzip**: Extract contents of a ZIP file.
- **grep**: Search for a pattern in files or input.
- **sed**: Perform search-and-replace on file contents.
- **which**: Find the full path of a command.
- **export**: Set an environment variable.
- **pkill**: Terminate processes by name.
- **pgrep**: Get information about processes by name.
- **head**: Display the first few lines of a file.
- **tail**: Display the last few lines of a file.
- **nf**: Create a new empty file.
- **mkcd**: Create a new directory and change to it.
- **docs, dtop, dload**: Change to Documents, Desktop, or Downloads folder.
- **la, ll**: List directory contents (including hidden files).
- **gs, ga, gc, gp**: Git status, add, commit, and push shortcuts.
- **gcl, gcom, lazyg**: Git clone, commit, and lazy git (add, commit, push).
- **sysinfo**: Display system information.
- **flushdns**: Clear the DNS client cache.
- **cpy, pst**: Copy to and paste from clipboard.
- **dcu**: Run `docker-compose up` in the current directory.
- **dcd**: Run `docker-compose down` in the current directory.
- **dcb**: Run `docker-compose build` in the current directory.
- **dcl**: Run `docker-compose logs` in the current directory.
- **dcr**: Run `docker-compose restart` in the current directory.
- **dps**: List containers managed by `docker-compose`.
- **dce**: Execute a command in a running container.
- **dcp**: Pull service images defined in `docker-compose`.
- **restart**: Restart the PowerShell shell.

## 🙏 Acknowledgements

I would like to extend my gratitude to [Chris Titus Tech](https://github.com/ChrisTitusTech) for his excellent PowerShell profile, which served as the foundation for my own customizations. His repository is a treasure trove of useful configurations and scripts, and I highly recommend visiting his [PowerShell Profile repository](https://github.com/ChrisTitusTech/powershell-profile) for more advanced setups.


---

Feel free to contribute to this repository by submitting issues or pull requests. Your feedback and suggestions are always welcome!

Happy scripting! 🎉