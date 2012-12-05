di-dropbox
==========

Download and install latest Dropbox for Mac

I've got a bunch of these… "di-" always stands for "Download and Install".

The script is thoroughly commented.  A few highlights:

* You could run this script once a day via cron or launchd. If you already have the latest version, it will just leave it alone.

* You will want to edit the script to redefine DIR. Most people probably want

	DIR=$HOME/Downloads

but I don't, so I left it as I use it.

* If download a new version, the script assumes that you want to install it.

* The script will automatically quit Dropbox (if it is running), move the old version to ~/.Trash/, and then launch the new version. The whole idea is that you would never even know that anything had changed.

* The new version is installed to /Applications/ using 'ditto' … if you want it installed elsewhere, you'll need to edit that part of the script

* The DMG will be mounted and unmounted automatically, but will not be deleted. This is intentional, in case you want to download the DMG to your Dropbox and install it on multiple computers.

* The core of this script is scraping Dropbox's web forums looking for particular keywords. This provides all of the stability and reliability of a pogo-stick on uneven ice.

* Dropbox used to redirect <http://forums.dropbox.com/forum-build.php> to the latest forum build automatically, but that broke and they don't seem to be in any rush to fix it, and I have no interest in checking their web forum every day to see if a new build has been released.

* These builds will almost always be beta. Use with caution, etc.

* If this script breaks anything, it's not my fault. That's the license agreement. Other than that, use, fork and distribute freely. If your country prohibits such terms, then this script is not available for use in your country.
