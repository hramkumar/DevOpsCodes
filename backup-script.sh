# $ mkdir -p /tmp/scripts/logs
# $ cd /tmp/scripts/logs
# $ touch ansible.log apache.log mysql.log nagios.log

# $ vim backup_files.txt
# apache.log
# mysql.log
# nagios.log
# ansible.log
# chef.log

#!/bin/bash
LOG_DIR='/tmp/scripts/logs'
BACKUP_DIR='/tmp/scripts/logs_backup'
mkdir -p $BACKUP_DIR
for files in $(cat backup_files.txt)
do
	if [-f $LOG_DIR/$files]
	then
		echo "Copying $files to logs_backup directory.."
		cp $LOG_DIR/$files $BACKUP_DIR
	else
		echo "$files log file already exist, skipping.."
	fi
done
echo ""
echo ""
echo "Archiving log files.."
tar -czvf logs_backup.tgz logs_backup
echo ""
echo ""
date
echo "Backup completed successfully.."
