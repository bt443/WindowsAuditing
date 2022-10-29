
#region -  Get last week's datetime range
$currentWeekday = get-date -format 'dddd'
$startDateTime = $null
$endDateTime = $null

switch ($currentWeekday) {
    'Sunday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 7)
        $endDateTime = (get-date) - (New-TimeSpan -day 1)        
    }

    'Monday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 8)
        $endDateTime = (get-date) - (New-TimeSpan -day 2)
    }

    'Tuesday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 9)
        $endDateTime = (get-date) - (New-TimeSpan -day 3)
    }

    'Wednesday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 10)
        $endDateTime = (get-date) - (New-TimeSpan -day 4)
    }

    'Thursday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 11)
        $endDateTime = (get-date) - (New-TimeSpan -day 5)
    }
    
    'Friday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 112)
        $endDateTime = (get-date) - (New-TimeSpan -day 6)
    }

    'Saturday' {
        $startDateTime = (get-date) - (New-TimeSpan -day 13)
        $endDateTime = (get-date) - (New-TimeSpan -day 7)
    }
}


$startDate = "$($startDateTime.year)-$($startDateTime.month)-$($startDateTime.day)"
$endDate = "$($endDateTime.year)-$($endDateTime.month)-$($endDateTime.day)"
#endregion


#region - get logs for each log type
$logTypes = 'system','security','application'
foreach ($log in $logTypes) {

    # create xml query for current logtype selected
    $xmlQuery = @"
        <QueryList>
          <Query Id="0" Path="$($log)">
            <Select Path="$($log)">*[System[TimeCreated[@SystemTime&gt;='$($startDate)T07:00:00.000Z' and @SystemTime&lt;='$($endDate)T06:59:59.999Z']]]</Select>
          </Query>
        </QueryList>
"@
    switch ($log) {
        'system' { 
            $systemLogFiles = Get-WinEvent -FilterXml $xmlQuery 
        }
        'security' {
            $securityLogFiles = Get-WinEvent -FilterXml $xmlQuery 
        }
        'application' { 
            $applicationLogFiles = Get-WinEvent -filterxml $xmlQuery 
        }   
    }
}

#endregion



break

###################### Reference code from get-winevent man document ################################3


# Using the Where-Object cmdlet:
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
Get-WinEvent -LogName 'Windows PowerShell' | Where-Object { $_.TimeCreated -ge $Yesterday }

# Using the FilterHashtable parameter:
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
Get-WinEvent -FilterHashtable @{ LogName='Windows PowerShell'; Level=3; StartTime=$Yesterday }

# Using the FilterXML parameter:
$xmlQuery = @'
<QueryList>
  <Query Id="0" Path="Windows PowerShell">
    <Select Path="System">*[System[(Level=3) and
        TimeCreated[timediff(@SystemTime) <= 86400000]]]</Select>
  </Query>
</QueryList>
'@
Get-WinEvent -FilterXML $xmlQuery

# Using the FilterXPath parameter:
$XPath = '*[System[Level=3 and TimeCreated[timediff(@SystemTime) <= 86400000]]]'
Get-WinEvent -LogName 'Windows PowerShell' -FilterXPath $XPath