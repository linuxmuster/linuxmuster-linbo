#!/bin/bash
#
# read log mail from stdin
#
# 11.10.2008
# Thomas Schmitt
# <schmitt@lmz-bw.de>

sessiondate="$(date)"
errorlog=/var/log/linuxmuster/linbo/log_error.log

exit_error() {
	msg="$1"
	echo "$sessiondate:" >> $errorlog
	echo "  $msg" >> $errorlog
	echo "  $sender" >> $errorlog
	exit 0
}

while read line; do

	# grep sender for errors
	if echo "$line" | grep ^"From:"; then
		sender="$line"
	fi

	# grep sending host/mailer for unauthorized mails
	if echo "$line" | grep ^"Received: by"; then
		sending_host=`echo $line | awk '{ print $3 }'`
		awk -F\; '{ print $2 }' /etc/linuxmuster/workstations | grep -qx "$sending_host" || exit_error "Unauthorized sending host: $sending_host!"
		sending_mailer=`echo $line | awk -F\( '{ print $2 }' | awk -F\) '{ print $1 }'`
		[ "$sending_mailer" = "sSMTP sendmail emulation" ] || exit_error "Unauthorized sending mailer: $sending_mailer!"
	fi

	# grep hostname and logfile from subject
	if echo "$line" | grep ^"Subject: LOG"; then
		logname="$(echo "$line" | awk '{ print $3 }')"

		if [ -z "$logname" ]; then
			exit_error "Cannot determine hostname!"
		elif ! awk -F\; '{ print $2 }' /etc/linuxmuster/workstations | grep -qx "$logname"; then
			exit_error "Unknown hostname $logname!"
		fi
		logfile="$(echo "$line" | awk '{ print $4 }')"
		if [ -z "$logfile" ]; then
			exit_error "Cannot determine logfile!"
		fi
		case "$logfile" in
			linbo.log|patch.log|image.log) ;;
			*) exit_error "Unknown logfile $logfile" ;;
		esac
		[ "$sending_host" = "$logname" ] || exit_error "Sending host $sending_host does not match hostname $logname given in subject!"
	fi

	if [ -z "$line" ]; then
		header_read=yes
		continue
	fi

	[ -z "$header_read" -o -z "$logname" -o -z "$logfile" ] && continue

	[ -z "$linbolog" ] && linbolog="/var/log/linuxmuster/linbo/${logname}_${logfile%.log}.log"

	if [ -z "$date_printed" ]; then
		echo >> $linbolog
		echo "### New session started at $sessiondate ###" >> $linbolog
		date_printed=yes
	fi

	echo "$line" | recode lat1..utf8 >> $linbolog

done

