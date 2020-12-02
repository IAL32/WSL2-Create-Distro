# WSL2 Create Distro
Creates a distro from a tarball and optionally adds a user to it

As a general pourpose, when working for different projects or companies,
one might need to create a self-contained WSL environment, just as one creates a
Virtual Machine.
This script will do just that. It creates a WSL distribution from a tarball file,
and optionally creates a user and adds it to a group (sudo by default).

# Install

The script presumes that you have WSL installed, and uses WSL2 as the default WSL
version. I haven't tested with WSL1. If you want to see some instructions on how
to install WSL2, you can find them here: https://docs.microsoft.com/en-us/windows/wsl/install-win10

Apart from that there is nothing to install really. You can just copy and paste the code into a PS1
file wherever you want, or:

Clone the repository locally:  
`git clone https://github.com/IAL32/WSL2-Create-Distro.git`

Change the working directory:  
`cd .\WSL-Create-Distro`

And then use the script!

If you have noticed, if you created a user, it won't have a password set. That's ok! We can always
use the function [here](https://github.com/microsoft/WSL/issues/3974#issuecomment-522921145):

```{powershell}
Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq <YOUR_DISTRONAME> | Set-ItemProperty -Name DefaultUid -Value ((wsl -d <YOUR_DISTRONAME> -u root -e id -u) | Out-String);
```

And set the user back to `root` (if it wasn't already). From here, we can then change
the user's password:
```
passwd <USERNAME>
```
and also, while we are at it, we can do the same for the root user:
```
passwd
```

The last thing would be to set `/bin/bash` as the default shell for the new user.
This is necessary, as WSL bindings to Windows will only work if `bash` is used as
the default shell.

We just need to login with your user, and launch:
```
chsh
```

The command will then ask for your password, and the path of the shell you want to
use. Just type:

```
/bin/bash
```

And that's it!

# Usage

```
PS C:\> Get-Help .\Create-Linux-Distro.ps1

NAME
    C:\Users\Adi\Desktop\Create-Linux-Distro.ps1

SYNOPSIS
    Creates a WSL2 distro and optionally adds a user with group

SYNTAX
    C:\Users\Adi\Desktop\Create-Linux-Distro.ps1 [-INPUT_FILENAME] <FileInfo> -OUTPUT_DIRNAME <FileInfo>
    -OUTPUT_DISTRONAME <Object> [-CREATE_USER <Boolean>] [-CREATE_USER_USERNAME <Object>] [-ADD_USER_TO_GROUP <Boolean>]    
    [-ADD_USER_TO_GROUP_NAME <Object>] [-SET_USER_AS_DEFAULT <Boolean>] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIZIONE
    As a general pourpose, when working for different projects or companies,
    one might need to create a self-contained WSL environment, just as one creates a
    Virtual Machine.
    This script will do just that. It creates a WSL distribution from a tarball file,
    and optionally creates a user and adds it to a group (sudo by default).
```

# Examples

Creates a WSL2 instance using Ubuntu20.04 (Focal Fossa) using a previously downloaded
tarball (the example uses the following one: https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-wsl.rootfs.tar.gz), creates a user with username `test1`
and adds it to the group `sudo`.

```
CreateLinuxDistro.ps1 -INPUT_FILENAME focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "$env:LOCALAPPDATA\Packages\ubuntu2004-1" -OUTPUT_DISTRONAME ubuntu2004-1 -CREATE_USER $true -CREATE_USER_USERNAME test1 -ADD_USER_TO_GROUP $true -ADD_USER_TO_GROUP_NAME sudo
```

# Delete WSL2 distribution

As stated in the [official documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
you can delete a WSL2 distribution using the following command:

```wsl --unregister <DistributionName>```
