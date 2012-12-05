#!/bin/zsh
# scrap Dropbox forum looking for latest Dropbox beta
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2012-10-30

NAME="$0:t"

	# This is where we will store the download, if a new one is found
DIR="$HOME/Dropbox/Apps/site44/d.luo.ma/dropbox"

	# If that directory does not exist, create it
[[ -d "$DIR" ]] || mkdir -p "$DIR"

	# Change to the directory
cd "$DIR"

	# first we look for a post marked as an 'experimental build' but NOT for iOS or Android
BUILD_POST=$(curl -sL "https://forums.dropbox.com" | fgrep 'Experimental Build' | egrep -v 'android|ios' | sed 's#">.*##g ; s#.*"##g')

	# If we don't find that, we look for a post marked as a 'Stable Build' (but not for iOS or Android)
[[ "$BUILD_POST" == "" ]] && \
BUILD_POST=$(curl -sL "https://forums.dropbox.com" | fgrep 'Stable Build' | egrep -v 'android|ios' | sed 's#">.*##g ; s#.*"##g')

	# If BUILD_POST is empty, we didn't find either, so let's give up
[[ "$BUILD_POST" == "" ]] && die "No experimental or stable build found"

	# Now that we have found the post, dump its contents and look for a
	# '.dmg' file take the first one we find (which may be a bad idea, we
	# might want the last one, but so far it hasn't come up) process the
	# text to do our best to get only the URL on a single line
DMG_URL=$(curl -sL "$BUILD_POST" | fgrep .dmg | head -1 | tr '"|>|<' '\012' | fgrep '://' | sort -u)

	# Now we look for what the filename would be called if we saved the
	# current build. We replace '%20' with a space because we are not
	# animals.
FILENAME=$(echo "$DIR/$DMG_URL:t" | sed 's#%20# #g' )

	# If that file does NOT exist, assume that we have the most current build
[[ -e "$FILENAME" ]] || wget -c -P "$DIR" "$DMG_URL"

	# What is the installed version? Numbers only
INSTALLED_VERSION=$(fgrep -A1 CFBundleVersion /Applications/Dropbox.app/Contents/Info.plist | tr -cd '[0-9]')

	# What is the most recent version? Numbers only
MOST_RECENT_VERSION=$(ls -1 *dmg | tail -1 |tr -cd '[0-9]')

	# If the most recent version is the same as the installed version, our work here is done
[[ "$MOST_RECENT_VERSION" == "$INSTALLED_VERSION" ]] && exit 0


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
# If Dropbox is running

PID=$(pgrep Dropbox)

while [ "$PID" != "" ]
do
	echo "$NAME: Trying to get Dropbox to quit PID = $PID"

		# Tell Dropbox to quit
	osascript -e 'tell application "Dropbox" to quit'

		# give it a few seconds to comply
	sleep 5

		# check to see if it is running
	PID=$(pgrep Dropbox)

done

	# This will mount the DMG quietly and make '$MNTPNT' equal to the mount point

MNTPNT=$(echo "Y" | hdid -plist "$FILENAME" 2>/dev/null | fgrep -A 1 '<key>mount-point</key>' | tail -1 | sed 's#</string>.*##g ; s#.*<string>##g')

APP='/Applications/Dropbox.app'

	# if the app is already installed, move it to the trash
[[ -e "$APP" ]] && command mv -vf "$APP" "$HOME/.Trash/Dropbox.$INSTALLED_VERSION"

ditto -v "$MNTPNT/Dropbox.app" "$APP" && \
	echo "$NAME: Installed new version of Dropbox"

open "$APP" && echo "$NAME: Launched Dropbox"

while [ -d "$MNTPNT" ]
do

	echo "$NAME: Trying to unmount $MNTPNT"

	diskutil unmount "$MNTPNT"

	sleep 5

done

exit 0

#
#EOF
