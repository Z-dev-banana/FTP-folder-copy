# WHO DONE WROTE THIS: ZACH S
# Before running this, make the following folders at the correct locations: 
#  C:\Temp and C:\Temp\$WavFolder
# I would have made them through <the code> but if I do it requires admin access and we want non-admins to use this script.
# 
# Needs to allow scripts to run before this can work properly, use "Set-ExecutionPolicy remotesigned" in admin PowerShell

$server   = "ftp.server.ip"
$username    = "user"
$password    = "pass"
$directory   = "server/folder/directory"
$WavFolder = "Final_File"

$ftp = [System.Net.FtpWebRequest]::create("ftp://$server/$directory")
$ftp.Credentials =  New-Object System.Net.NetworkCredential($username,$password)
$ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
$response = $ftp.GetResponse()
$responseStream = $response.GetResponseStream()
$readStream = New-Object System.IO.StreamReader $responseStream

while ($file = $readStream.ReadLine()) {
  if ($file.Substring($file.Length-4) -eq ".wav") {
    $dateRecorded = $file.Split(" ")[-4] + " " + $file.Split(" ")[-3]
    $currentDate = Get-Date -UFormat "%b %y"
    if ($currentDate -eq $dateRecorded) {
        $filename = $file.Split(" ")[-1]
        $LocalFile = "C:\Temp\$WavFolder\" + $filename

        # Create a FTPWebRequest
        $FTPRequest = [System.Net.FtpWebRequest]::Create("ftp://$server/$directory/$filename")
        $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($username,$password)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
        $FTPRequest.UseBinary = $true
        $FTPRequest.KeepAlive = $false

        # Send the ftp request
        $FTPResponse = $FTPRequest.GetResponse()

        # Get a download stream from the server response
        $ResponseStream = $FTPResponse.GetResponseStream()

        # Create the target file on the local system and the download buffer
        $LocalFileFile = New-Object IO.FileStream ($LocalFile,[IO.FileMode]::Create)
        [byte[]]$ReadBuffer = New-Object byte[] 1024

        # Loop through the download
        do {
        $ReadLength = $ResponseStream.Read($ReadBuffer,0,1024)
        $LocalFileFile.Write($ReadBuffer,0,$ReadLength)
        }
        while ($ReadLength -ne 0)
    }
  } 
}

Invoke-Item C:\Temp\$WavFolder