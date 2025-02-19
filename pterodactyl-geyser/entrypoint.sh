#!/bin/bash
cd /home/container

# Output Current Java Version
java -version

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Check auto update is on
if [ "${AUTO_UPDATE}" == "1" ]; then
	echo "Checking for updates..."

	LATEST_HASH=`curl -L https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest | jq -r .downloads.standalone.sha256`
	CURRENT_HASH=`cat .currenthash 2>/dev/null`

	if [ "$LATEST_HASH" != "$CURRENT_HASH" ]; then
		echo "Update available!"
		echo "Updating from '$CURRENT_HASH' -> '$LATEST_HASH'"
		curl -s -o ${SERVER_JARFILE} https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone

		echo "$LATEST_HASH" > ".currenthash"
		echo "Updated!"
	else
		echo "No update available"
	fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
