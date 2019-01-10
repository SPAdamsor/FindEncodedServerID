# FindEncodedServerID
Find SharePoint EncodedServerID within correlation ID

This can be run on servers in the SharePoint farm which will return the server name.  We would still need to run "Get-SPServer | select address, EncodedServerId" on a SharePoint server in the farm to get a list of the EncodedServerId.

