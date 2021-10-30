[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/ste-giraldo/cisco-dna-backup-cleaner)

# cisco_dna_backup_cleaner.sh
Cisco DNA Center is able to create scheduled system backups, but there's not way to remove old backups, hence deleting should be done manually from DNA-C. Pretty annoying...
I wrote this Bash script to automatically removing old backups basing on a retention period. 

This script runs on GNU and require "curl" and "jq" packets installed, to working properly. Is intended to run from the path ~/script, but of course can be changed.

Edit the script to change the URLs pointing to the hostname of your DNA-C installation. Please use cluster URL in case of 3 node deployment.
Change also the base64 autorization key (currently ABC123= as placeholder), matching with your username and password used on DNA-C.
Change also the RETENTION value in order to match your needs.

In my case, I scheduled the backups from DNA-C at Friday 9pm and the script runs from crontab at 11.30pm:

30 23 * * 5 /bin/bash /PATH_TO/scripts/cisco_dna_backup_cleaner.sh >/dev/null 2>&1

**Screenshot of a run:**
![Screenshot of a run](https://i.imgur.com/MTdt5dT.jpg)
