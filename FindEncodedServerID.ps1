##Find-EncodedServerID
##Author:adamsor; adamsorenson.com
##Version: 1.1
##Time is encoded by GMT.  Timeoffset will change it to the server's time zone.  -7 would be PST
##Example: Find-EncodedServerId 3c1f889f-096a-708b-2631-a9b8cbc3415e -TimeOffSet -7

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
$ErrorActionPreference = "SilentlyContinue"
Function Find-EncodedServerId
{
    param([guid]$corID,
        [int]$TimeOffSet=0
        )


        #This code calls to a Microsoft web endpoint to track how often it is used. 
        #No data is sent on this call other than the application identifier
        Add-Type -AssemblyName System.Net.Http
        $client = New-Object -TypeName System.Net.Http.Httpclient
        $cont = New-Object -TypeName System.Net.Http.StringContent("", [system.text.encoding]::UTF8, "application/json")
        $tsk = $client.PostAsync("https://msapptracker.azurewebsites.net/api/Hits/22f91595-837b-4205-be08-8accea0eaf7d",$cont)
        #if you want to make sure the call completes, add this to the end of your code
        #$tsk.Wait()

    $server = $null

    $bytes = $corID.ToByteArray()
    [int]$b8 = $bytes[8]
    [int]$p8 = $b8 -shl 12
    [int]$b9 = $bytes[9]
    [int]$p9 = $b9 -shl 4
    [int]$b10 = $bytes[10]
    [int]$p10 = $b10 -shr 4
    $esid= $p8 + $p9 + $p10

    [int64]$b0 = $bytes[0]
    [int64]$p0 = $b0 -shl 36
    [int64]$b1 = $bytes[1]
    [int64]$p1 = $b1 -shl 28
    [int64]$b2 = $bytes[2]
    [int64]$p2 = $b2 -shl 20
    [int64]$b3 = $bytes[3]
    [int64]$p3 = $b3 -shl 12
    [int64]$b4 = $bytes[4]
    [int64]$p4 = $b4 -shl 4
    [int64]$b5 = $bytes[5]
    [int64]$p5 = $b5 -shr 4
    [int64]$44 = 52776558133248
    [int64]$tsid= $p0 + $p1 + $p2 + $p3 + $p4 + $p5 + $44
    
    $timeGMT = Get-Date $($tsid*10000)
    $offset = New-TimeSpan -Hours $TimeOffSet
    $timeo = $timeGMT + $offset
    $time = Get-Date $timeo  -Format "MMMM d, yyyy HH:mm:ss.fff"
    
    $server = Get-SPServer  | ? {$_.EncodedServerID -eq $esid} 
    $ad= $server.address


    If($server -ne $null)
    {
        Write-Host "Estimated Server Time of the Correlation ID: $time" -ForegroundColor Yellow
        Write-Host "CorrelationID $corID translates to $esid, $ad" -ForegroundColor Green
    }
    Else
        {
            Write-Host "Estimated Server Time of the Correlation ID: $time" -ForegroundColor Yellow
            write-host "Did not find servers while decoding CorrelationID $corID please run the following PS:" -ForegroundColor Red
            write-host "Get-SPServer | select address, EncodedServerId" -ForegroundColor Green
            "EncodedServerID: " + $esid

        }
}
####END