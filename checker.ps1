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
    if (-not $i.StartsWith('https://')){
        $url = "https://"+$i
    }else{
        $url = $i
    }
    $statusCode = 0
    $statusCode = Invoke-WebRequest -Uri $url -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 10 | Select-Object -Expand StatusCode
    if ($statusCode -eq 307 -or $statusCode -eq 0){
        Write-Host $url "is blocked:" $statusCode
    }elseif ($statusCode -ge 300 -and $statusCode -lt 400) {
        Write-Host $url " was redirected with a code of" $statusCode
    }elseif ($statusCode -ge 400 -and $statusCode -lt 500){
        Write-Host "There was a client error when trying to reach" $url". The code is " $statusCode
    }elseif ($statusCode -ge 400 -and $statusCode -lt 500){
        Write-Host "There was a server error when trying to reach" $url". The code is " $statusCode
    }elseif ($statusCode -ge 200 -and $statusCode -le 203){
        Write-Host $url "is unblocked:" $statusCode
        $unblockedString += "," + $url + " " + $statusCode
    }else{
        Write-Host $url "did an edge case"
    }
}
$unblockedString = $unblockedString -replace ",","`n"
$unblockedString | Out-File .\$outFilename 