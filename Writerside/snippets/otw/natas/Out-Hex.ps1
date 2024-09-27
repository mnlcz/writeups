function Out-Hex {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$InputB64
    )

    foreach ($In in $InputB64) {
        $Bytes = [Convert]::FromBase64String($In)
        $Hex = $Bytes | Format-Hex
        Write-Output $Hex
    }
}