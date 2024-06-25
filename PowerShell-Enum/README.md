# AD Enumeration Scripts

## Description
A collection of PS scripts and commands I use on a regular basis for AD enum

## Files

| File | Description |
|:--- |:--- |
| `userlist.ps1` | Domain user account enumeration using LDAP queries with the native `DirectoryServices.DirectorySearcher` type. Filters only enabled accounts. Needs updating to include MSAs and gMSAs |
| `computerlist.ps1` | Domain computer enumeration using LDAP queries. Collects name, DNS, IP, description, OS, and lastlogon properties from the AD objects |


