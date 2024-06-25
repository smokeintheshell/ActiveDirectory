invoke-command -ScriptBlock { 
    Set-Location -Path $env:LOCALAPPDATA
    #$dc = $env:logonserver.trim('\')
    $dc = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).PdcRoleOwner.name
    $dcip = (resolve-dnsname -Type A $dc)[0].ipaddress
    $Searcher = New-Object DirectoryServices.DirectorySearcher
    $dcroot = $Searcher.SearchRoot.distinguishedname
    #$dcsearch = $env:userdnsdomain.split('.')
    #$dcroot = 'DC=' + ($dcsearch -join ',DC=')
    $searchroot = "LDAP://" + $dcip + ":389/$dcroot"
    $Searcher.SearchRoot = $searchroot
    $Searcher.Filter = '(&(objectCategory=computer)(!userAccountControl:1.2.840.113556.1.4.803:=2))'
    $Searcher.PageSize = 10000
    $res = $Searcher.FindAll() | Sort-Object path
    $computers = New-Object System.Collections.Generic.List[System.Object]
    foreach ($compTmp in $res)
    {
      $compTmpDns = $compTmp.properties.dnshostname
      $compTmpIPv4 = (Resolve-DnsName $compTmpDns -type A -ea sile).ip4address
      $compTmpLastLogon = [datetime]::FromFileTimeUtc([string]($compTmp.Properties.lastlogontimestamp))
      $computer = [pscustomobject]@{
        'name' = $compTmp.Properties.name -Join '; '
        'dnshostname' = $compTmp.Properties.dnshostname -Join '; '
        'ipv4address' = $compTmpIPv4 -join '; '
        'description' = $compTmp.Properties.description -join '; '
        'operatingsystem' = $compTmp.Properties.operatingsystem -join ';'
        'lastlogon' = $compTmpLastLogon -join ':'
        #'memberof' = $compTmp.Properties.memberof  -Join '; '
      }
      $computers.Add($computer)
    }
    $computers | Export-Csv -Encoding ascii -NoTypeInformation -Delimiter "`t" -path computers.tsv
}
