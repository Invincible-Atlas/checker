# Instructions:
# put the list of urls in a file that is in the same folder as this program
# Make sure that each entry of the list is separated by a line break, for example:
# example.com
# otherexample.com
# then, run the program, and put the name of the file (including the file extension) for input filename, and the name of the file that will contain a list of all the unblocked sites for output filename
# To run the program, you can:
#   open the program in vscode, install the PowerShell extension (vscode should prompt you to install it when you open a .ps1 file) and click on the play button in the top right corner,
#   copy the code into Windows PowerShell ISE, and click the play button(to copy the code in, select file>new, or click the page with star icon),
#   or you can probably run it by right-clicking on the file and clicking open with, but I haven't been able to get that to work.
$filename = Read-Host "Input Filename"
$outFilename = Read-Host "Output Filename"
$urlString = Get-Content $filename
$urlList =  $urlString -Split "`n"
$unblockedString = ""
foreach ($i in $urlList){
    $statusCode = Invoke-WebRequest -Uri $i -UseBasicParsing -MaximumRedirection 0 | Select-Object -Expand StatusCode
    if ($statusCode -eq 307){
        Write-Host $i " is blocked"
    }elseif ($statusCode -ge 300 -and $statusCode -lt 400) {
        Write-Host $i " was redirected with a code of " $statusCode
    }elseif ($statusCode -ge 400 -and $statusCode -lt 500){
        Write-Host "There was a client error when trying to reach " $i ". The code is " $statusCode
    }elseif ($statusCode -ge 400 -and $statusCode -lt 500){
        Write-Host "There was a server error when trying to reach " $i ". The code is " $statusCode
    }else{
        Write-Host $i " is unblocked"
        $unblockedString += "," + $i
    }
}
$unblockedString = $unblockedString -replace ",","`n"
$unblockedString | Out-File .\$outFilename 