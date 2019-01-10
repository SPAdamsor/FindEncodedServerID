##The information that is  provided "as is" without warranty of any kind. We disclaim all warranties, either express or implied, including the warranties of merchantability and fitness for a particular purpose. In no event shall Microsoft Corporation or its suppliers be liable for any damages whatsoever including direct, indirect, incidental, consequential, loss of business profits or special damages, even if Microsoft Corporation or its suppliers have been advised of the possibility of such damages. Some states do not allow the exclusion or limitation of liability for consequential or incidental damages. Therefore, the foregoing limitation may not apply.
##Find the server that issued the correlationID
##Author:adamsor; https://adamsorenson.com

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue
$ErrorActionPreference = "SilentlyContinue"
Function Find-EncodedServerId
{
param([guid]$corID)

        #This code calls to a Microsoft web endpoint to track how often it is used. 
        #No data is sent on this call other than the application identifier
        Add-Type -AssemblyName System.Net.Http
        $client = New-Object -TypeName System.Net.Http.Httpclient
        $cont = New-Object -TypeName System.Net.Http.StringContent("", [system.text.encoding]::UTF8, "application/json")
        $tsk = $client.PostAsync("https://msapptracker.azurewebsites.net/api/Hits/6609208e-651e-4642-8247-4a0008a93958",$cont)
        #if you want to make sure the call completes, add this to the end of your code
        #$tsk.Wait()

	$server = $null

	$bytes = $corID.ToByteArray()
	[int]$b8 = $bytes[8]
	[int]$p1 = $b8 -shl 12
	[int]$b9 = $bytes[9]
	[int]$p2 = $b9 -shl 4
	[int]$b10 = $bytes[10]
	[int]$p3 = $b10 -shr 4
	$esid= $p1 + $p2 + $p3

	$server = Get-SPServer  | ? {$_.EncodedServerID -eq $esid} 
	$ad= $server.address


	If($server -ne $null)
    	{
    		Write-Host "CorrelationID $corID translates to $esid, $ad" -ForegroundColor Green
    	}
	Else
    	{
    		write-host "Did not find servers while decoding CorrelationID $corID please run the following PS:" -ForegroundColor Red
    		write-host "Get-SPServer | select address, EncodedServerId" -ForegroundColor Green
    		"EncodedServerID: " + $esid
    	}
}
