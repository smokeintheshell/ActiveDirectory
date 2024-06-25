invoke-command -ScriptBlock { 
    Set-Location -Path $env:LOCALAPPDATA
    $dc = $env:logonserver.trim('\')
    $dcip = (resolve-dnsname -Type A $dc)[0].ipaddress
    $dcsearch = $env:userdnsdomain.split('.')
    $dcroot = 'DC=' + ($dcsearch -join ',DC=')
    $searchroot = "LDAP://" + $dcip + ":389/$dcroot"
    $Searcher = New-Object DirectoryServices.DirectorySearcher
    $Searcher.SearchRoot = $searchroot
    $Searcher.Filter = '(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2)(sAMAccountName=*))'
    # (&(objectClass=user)(|(objectCategory=person)(objectCategory=msDS-GroupManagedServiceAccount)(objectCategory=msDS-ManagedServiceAccount)))
    $Searcher.PageSize = 10000
    $res = $Searcher.FindAll() | Sort-Object path
    $users = New-Object System.Collections.Generic.List[System.Object]
    foreach ($usrTmp in $res)
    {
      $user = [pscustomobject]@{
        'userprincipalname' = $usrTmp.Properties.userprincipalname -Join '; '
        'samaccountname' = $usrTmp.Properties.samaccountname -Join '; '
        'displayname' = $usrTmp.Properties.displayname -Join '; '
        'mail' = $usrTmp.Properties.mail  -Join '; '
        'title' = $usrTmp.Properties.title  -Join '; '
        'department' = $usrTmp.Properties.department  -Join '; '
        'description' = $usrTmp.Properties.description  -Join '; '
        'memberof' = $usrTmp.Properties.memberof  -Join '; '
      }
      $users.Add($user)
    }
    $users | Export-Csv -notypeinformation -Encoding ascii -Delimiter "`t" -Path .\users.tsv
}
