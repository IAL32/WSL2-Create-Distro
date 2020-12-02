<#
.SYNOPSIS
    Creates a WSL2 distro and optionally adds a user with group
.DESCRIPTION
    As a general pourpose, when working for different projects or companies,
    one might need to create a self-contained WSL environment, just as one creates a
    Virtual Machine.
    This script will do just that. It creates a WSL distribution from a tarball file,
    and optionally creates a user and adds it to a group (sudo by default).
.EXAMPLE
    Create-Linux-Distro.ps1 -INPUT_FILENAME focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "%LOCALAPPDATA%/ubuntu2004-1" -OUTPUT_DISTRONAME ubuntu2004-1 -CREATE_USER $true -CREATE_USER_USERNAME test1 -ADD_USER_TO_GROUP $true -ADD_USER_TO_GROUP_NAME sudo
.EXAMPLE
    Create-Linux-Distro.ps1 -INPUT_FILENAME focal-server-cloudimg-amd64-wsl.rootfs.tar.gz -OUTPUT_DIRNAME "" -OUTPUT_DISTRONAME DISTRONAME -CREATE_USER $true -CREATE_USER_USERNAME test1 -ADD_USER_TO_GROUP $true -ADD_USER_TO_GROUP_NAME blabla
.INPUTS
    Help needed here!
.OUTPUTS
    Help needed here!
.NOTES
    Help needed here!
.COMPONENT
    Help needed here!
.ROLE
    Help needed here!
.FUNCTIONALITY
    Help needed here!
#>

[CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
    SupportsShouldProcess = $true,
    PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
[Alias()]
[OutputType([String])]
Param (
    # Input distribution tarball
    [Parameter(
        Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern(".tar.gz$")]
    [ValidateScript( {
            if ( -Not ($_ | Test-Path) ) {
                throw "File or folder does not exist"
            }
            return $true
        })]
    [System.IO.FileInfo]
    [Alias("i")] 
    $INPUT_FILENAME,

    # Where the distro will be saved
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]
    $OUTPUT_DIRNAME = "$env:LOCALAPPDATA/Packages/WSLDistributions",

    # The name of the distribution
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromRemainingArguments = $false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $OUTPUT_DISTRONAME,

    # Whether or not to create a user along with the distribution
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    [bool]
    $CREATE_USER = $false,

    # Username of the user to create
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("[a-zA-Z0-9]*")]
    $CREATE_USER_USERNAME,

    # Whether or not to automatically add the user to a group
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    [bool]
    $ADD_USER_TO_GROUP = $false,

    # Which group should the user be added to (default=sudo)
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    $ADD_USER_TO_GROUP_NAME = "sudo",

    # Which user should be set as the default
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromRemainingArguments = $false
    )]
    $SET_USER_AS_DEFAULT = "root"
)

begin {
}

process {

    if ($pscmdlet.ShouldProcess("Target", "Operation")) {
        Write-Output "Importing distro $OUTPUT_DISTRONAME using $INPUT_FILENAME to $OUTPUT_DIRNAME"
        wsl --import $OUTPUT_DISTRONAME $OUTPUT_DIRNAME $INPUT_FILENAME

        if ($CREATE_USER) {
            Write-Output "Creating user $CREATE_USER_USERNAME"
            wsl -d $OUTPUT_DISTRONAME /usr/sbin/useradd -m $CREATE_USER_USERNAME

            if ($ADD_USER_TO_GROUP) {
                Write-Output "Adding user $CREATE_USER_USERNAME to group $ADD_USER_TO_GROUP_NAME"
                wsl -d $OUTPUT_DISTRONAME /usr/sbin/adduser $CREATE_USER_USERNAME $ADD_USER_TO_GROUP_NAME
            }
        }
        # Curtesy of https://github.com/microsoft/WSL/issues/3974#issuecomment-522921145
        Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq $OUTPUT_DISTRONAME | Set-ItemProperty -Name DefaultUid -Value ((wsl -d $OUTPUT_DISTRONAME -u $SET_USER_AS_DEFAULT -e id -u) | Out-String);
    }

}

end {
}
