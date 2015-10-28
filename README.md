# Make-InfobloxBlacklist
DNS malware blacklist for Infoblox

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
