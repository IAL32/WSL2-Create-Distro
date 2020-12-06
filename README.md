# WSL2 Create Distro
Creates a distro from a tarball and optionally adds a user to it

As a general pourpose, when working in different projects or companies,
one might need to create a self-contained WSL environment, just as one creates a
Virtual Machine.
This script will do just that. It creates a WSL distribution from a tarball file,
and optionally creates a user and adds it to a group (sudo by default). Additionally,
it will set a default shell (for WSL with Ubuntu the default shell is `/bin/bash`)
and optionally a default user.

The whole process takes 10 seconds approximately.

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
NOME
    .\CreateLinuxDistro.ps1

RIEPILOGO
    Creates a WSL2 distro and optionally adds a user with group


SINTASSI
    .\CreateLinuxDistro.ps1 [-INPUT_FILENAME] <FileInfo> -OUTPUT_DIRNAME <FileInfo> -OUTPUT_DISTRONAME <Object> [-DEFAULT_SHELL <Object>] [-SET_USER_AS_DEFAULT <Object>]
    -ROOT_PASSWORD <Object> [-WhatIf] [-Confirm] [<CommonParameters>]

    .\CreateLinuxDistro.ps1 [-INPUT_FILENAME] <FileInfo> -OUTPUT_DIRNAME <FileInfo> -OUTPUT_DISTRONAME <Object> [-DEFAULT_SHELL <Object>] [-CREATE_USER <Boolean>]
    [-CREATE_USER_USERNAME <Object>] -CREATE_USER_PASSWORD <Object> [-ADD_USER_TO_GROUP <Boolean>] [-ADD_USER_TO_GROUP_NAME <Object>] [-SET_USER_AS_DEFAULT <Object>] -ROOT_PASSWORD <Object> [-WhatIf]  
    [-Confirm] [<CommonParameters>]


DESCRIZIONE
    As a general pourpose, when working for different projects or companies,
    one might need to create a self-contained WSL environment, just as one creates a
    Virtual Machine.
    This script will do just that. It creates a WSL distribution from a tarball file,
    and optionally creates a user and adds it to a group (sudo by default).


COLLEGAMENTI CORRELATI

COMMENTI
    Per visualizzare gli esempi, digitare: "get-help .\CreateLinuxDistro.ps1 -examples".
    Per ulteriori informazioni, digitare: "get-help .\CreateLinuxDistro.ps1 -detailed".
    Per informazioni di carattere tecnico, digitare: "get-help .\CreateLinuxDistro.ps1 -full".
```

# Examples

Creates a WSL2 instance using Ubuntu20.04 (Focal Fossa) using a previously downloaded
tarball (the example uses the following one: https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-wsl.rootfs.tar.gz), creates a user with username `myuser`
and adds it to the group `sudo`. It also sets the user password to the one given in the pipeline, and the password for the root user, also given in the pipeline.

```
.\CreateLinuxDistro.ps1 -INPUT_FILENAME .\focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "$env:LOCALAPPDATA\Packages\ubuntu2004-test-1" -OUTPUT_DISTRONAME ubuntu2004-test-1 -CREATE_USER 1 -CREATE_USER_USERNAME myuser -ADD_USER_TO_GROUP 1 -ADD_USER_TO_GROUP_NAME sudo -SET_USER_AS_DEFAULT myuser
```

# Delete WSL2 distribution

As stated in the [official documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
you can delete a WSL2 distribution using the following command:

```wsl --unregister <DistributionName>```
