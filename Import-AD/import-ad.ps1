function Import-AD {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$False, ParameterSetName="Disk")]
        [String]$Path,

        [Parameter(Mandatory=$False, ParameterSetName="HTTP")]
        [string]$URI,

        [Alias("User")]
        [Parameter(Mandatory=$False, ParameterSetName="HTTP")]
        [string]$Username,

        [Alias("Pass")]
        [Parameter(Mandatory=$False, ParameterSetName="HTTP")]
        [string]$Password
    )
    if ($Path) {
        try {
            $ADModPath = Resolve-Path $Path
            $ADModBytes = [io.file]::ReadAllBytes($ADModPath)
            $ADModAss = [System.Reflection.Assembly]::Load($ADModBytes)
            Import-Module -Assembly $ADModAss
        }
        catch { Write-Error "Failed to import ActiveDirectory module from: $ADModPath" }
    }
    elseif ($URI) {
        $wc = new-object net.webclient
        if ($Username -and $Password) {
            $UserPass = $Username + ":" + $Password
            $UPB64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$UserPass"))
            $AuthHead = @{Authorization="Basic $UPB64"}
            $wc.Headers['Authorization'] = $AuthHead.Authorization
        }
        try {
            $ADModBytes = $wc.DownloadData($URI)
            $ADModAss = [System.Reflection.Assembly]::Load($ADModBytes)
            Import-Module -Assembly $ADModAss
        }
        catch { Write-Error "Failed to import module from: $URI" }
    }
    else {
        $ADModExist = Get-Module -ListAvailable ActiveDirectory
        if ($ADModExist) {
            try { Import-Module ActiveDirectory }
            catch { Write-Error "Failed to import existing ActiveDirectory Module" }
        }
        else { Write-Error "No ActiveDirectoryModule available" }
    }
}
