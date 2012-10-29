#!/bin/bash
#
# read log mail from stdin
#
# 11.10.2008
# Thomas Schmitt
# <tschmitt@linuxmuster.de>
#
# 27.10.2012
# Yannik Sembritzki
# <yannik@sembritzki.me>
#

sessiondate="$(date -R)"
errorlog=/var/log/linuxmuster/linbo/log_error.log

exit_error() {
	msg="$1"
	echo "$sessiondate:" >> $errorlog
	echo "  $msg" >> $errorlog
	echo "  $sender" >> $errorlog
	exit 0
}

header_read=false
while read -r line; do

	if ! $header_read; then
		# assign line to var $sender if line starts with "From:" 
		if [[ $line ==  From:\ * ]]; then
			sender="$line"
		fi

		# check if host is authorized to send logs
		if [[ $line == Received:\ by* ]]; then
			sending_host=`echo $line | awk '{ print $3 }'`
			awk -F\; '{ print $2 }' /etc/linuxmuster/workstations | grep -qx "$sending_host" || exit_error "Unauthorized sending host: $sending_host!"
			sending_mailer=`echo $line | awk -F\( '{ print $2 }' | awk -F\) '{ print $1 }'`
			[ "$sending_mailer" = "sSMTP sendmail emulation" ] || exit_error "Unauthorized sending mailer: $sending_mailer!"
		fi

		# extract hostname and logfile from subject
		if [[ $line == Subject:\ LOG* ]]; then
			logname="$(echo "$line" | awk '{ print $3 }')"

			if [ -z "$logname" ]; then
				exit_error "Cannot determinate hostname!"
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
			header_read=true
			[ -z "$linbolog" ] && linbolog="/var/log/linuxmuster/linbo/${logname}_${logfile%.log}.log"
			if [ -z "$date_printed" ]; then
				echo >> $linbolog
				echo "### New session started at $sessiondate ###" >> $linbolog
				date_printed=yes
			fi		
		fi
	else # if $header_read
		echo "$line" >> $linbolog
	fi
done
