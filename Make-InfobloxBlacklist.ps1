<#
.SYNOPSIS
	This script downloads a list of malware domains and ultimately formats them
	into a csv format specifically for Infoblox for importing into a DNS blacklist.

.DESCRIPTION	
	Create an individual csv file for each domain category.  These will be added to 
	Infoblox as a blacklist, and any hits on these domains will be met with a redirect
	to an internal web page.  Users will then get hit with a splash page explaining
	why traffic is not allowed.

    The script creates the following directory to work from.  C:\blacklists\
    To change the working directory location, simply adjust the $TARGETURI string.

.EXCLUSIONS
    From time to time, it may be necessary to pull a domain out of the blacklist.  To
    account for this, the script creates an exclusion text file under the working directory.
    Just add each domain you want to exclude from the list on its own line within this 
    text file.  It will be retained each time the script is run.
	
.FUNCTIONS	
	The data is manipulated as rows, not columns.  So the functions add the content
	to the other column fields.  Such as adding the REDIRECT or BLOCK actions to each
	line, as well as what category.
	
.AUTHOR
	@thatchriseckert
	
.VERSION HISTORY
	1.0 - 06.24.2014
		Initial Version.
    1.1 - 2.20.2015
        Added exclusion list functionality.
#>


#MISC STRINGS AND FUNCTIONS AND WORKING DIRECTORIES, OH MY!
$date = Get-Date -Format MM-dd
$header = "Header-blacklistrule","parent*","domain_name*","action*"

function prepend-malware { 
  process{
   foreach-object {"BlacklistRule,malware," + $_}
    } 
  }
  
function append-redirect{
  process{
    foreach-object {$_ + ",REDIRECT"}
	}
  }
  
$TARGETDIR = "C:\blacklists\"
if(!(Test-Path -Path $TARGETDIR )){
   New-Item -ItemType directory -Path $TARGETDIR
}

if(!(Test-Path -path $TARGETDIR\exclusions.txt)){
    New-Item -ItemType file -Path $TARGETDIR\exclusions.txt
}
$EXCLUDELIST = gc "$TARGETDIR\exclusions.txt"


#DOWNLOAD MALWARE LIST
$malwaresource = "http://mirror1.malwaredomains.com/files/justdomains"
$malwaredestination = "$TARGETDIR\malwaredomains_$date.txt"
If (Test-Path $malwaredestination){
	Remove-Item $malwaredestination
}
$userAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)"
Write-Host "Downloading Fresh Malware List..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($malwaresource, $malwaredestination)


#CREATE MALWARE CSV (Where the magic happens)
Write-Host "Creating Malware CSV..."
Get-Content $TARGETDIR\malwaredomains_$date.txt | where { $_ -notmatch '\.\.|\:|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$|^localhost$' } | where { $EXCLUDELIST -notcontains $_} | prepend-malware | append-redirect >> $TARGETDIR\malwaretemp_$date.csv
Import-CSV -Delimiter "," -header $header $TARGETDIR\malwaretemp_$date.csv |
Export-CSV -NoTypeInformation $TARGETDIR\malware_domains_$date.csv


#HOUSEKEEPING
rm $TARGETDIR\malwaretemp_$date.csv
rm $TARGETDIR\malwaredomains_$date.txt

Write-Host "Done"
Write-Host "Malware blacklists below:"
Get-ChildItem -Path $TARGETDIR -Filter *.csv | sort-object CreationTime -Descending | Select name
