### BEGIN INIT INFO
# Provides:      network
# Required-Start:   $network $remote_fs $syslog
# Required-Stop:
# Default-Start:   S
# Default-Stop:
# Short-Description:   Delete Cisco DNA Center Scheduled Backups
# Author:   Stefano Giraldo & Damiano Di Mauro - Lutech S.p.A.
# Version: 2.0
### END INIT INFO

#!/bin/bash

# Change the RETENTION value to modify the number of backups to keep
RETENTION=5
echo "DNA Backups retention="$RETENTION

# Retrive the TokenID via BASE64 encoded username and password to operate against DNA Center via API
TOKEN="$(curl -s --insecure --request POST --url https://your.dna-center.local/dna/system/api/v1/auth/token  --header 'Authorization: basic ABC123=' --header 'content-type: application/json' | sed -e "s/{\"Token\":\"//" | sed -e "s/\"}//")"

# Repeating function to count the number of backups, retrive the BackupID list via JSON query and write to dna_bck_id.list file
REPEAT () {
  curl -s --insecure --request GET --url https://your.dna-center.local/api/system/v1/maglev/backup --header 'x-auth-token: '${TOKEN} --header 'content-type: application/json' | jq '.response[] | [.backup_id,.status,.description,.start_timestamp] | @csv' > ~/script/dna_bck_id.list

  COUNTER="$(cat ~/script/dna_bck_id.list | wc -l)"
  echo "Currently available Backups="$COUNTER
}
# End function

# Give the value to COUNTER for the first time with the number of online backups on DNA Center
REPEAT
while [ $COUNTER -gt $RETENTION ];
 do
 REPEAT

# Retriving BackupID to delete
  DEL_ID="$(cat ~/script/dna_bck_id.list | sort --field-separator=',' --key=4 | head -n 1 | awk -F "," {'print$1'} | cut -c 4- | sed 's/\\"//g';)"

  echo Deleting BackupID=$DEL_ID

# Send to DNA Center the request to delete the oldest backup
  curl --insecure --request DELETE --url https://your.dna-center.local/api/system/v1/maglev/backup/$DEL_ID --header 'x-auth-token: '${TOKEN} --header 'content-type: application/json' ; echo ; echo
  sleep 15s

# Revaluing COUNTER after delete
  curl -s --insecure --request GET --url https://your.dna-center.local/api/system/v1/maglev/backup --header 'x-auth-token: '${TOKEN} --header 'content-type: application/json' | jq '.response[] | [.backup_id,.status,.description,.start_timestamp] | @csv' > ~/script/dna_bck_id.list
  COUNTER="$(cat ~/script/dna_bck_id.list | wc -l)"
done

COUNTER="$(cat ~/script/dna_bck_id.list | wc -l)"
echo ""
echo "Final Backups counter="$COUNTER

#echo ""
#echo "No DNA Backups candidate for deleting"
#echo ""
