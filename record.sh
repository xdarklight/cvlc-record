#!/bin/bash

# DE: Dieses Script schmeißt die DVB-T-Aufnahme mithilfe des VLC Media Players an:

INFO="This script will start DVB-T and DVB-C recording via VLC Media Player's 'cvlc' tool."

FRONTEND_TYPE="dvb-t"
CHANNELS_CONF="channels.conf"
TUNING_OPTIONS=""

# Check parameters:
while [ ! -z "$1" ]
  do
	case "$1" in
		"-t") 	FRONTEND_TYPE="$2" 	&& shift && shift
			;;
		"-f") 	CHANNELS_CONF="$2" 	&& shift && shift
			;;
		"-c") 	CHANNEL="$2" 		&& shift && shift
			;;
		"-s") 	LIST_CHANNELS="true" 	&& shift && shift
			;;
		"-l") 	LENGTH="$2" 		&& shift && shift
			;;
		"-L") 	MINUTES="$2" 		&& shift && shift
			;;
		"-t") 	RECTIME="$2" 		&& shift && shift
			;;
		"-n") 	NAME="$2" 		&& shift && shift
			;;
		"-N") 	EXACTNAME="$2" 		&& shift && shift
			;;
		"-o") 	OUTPUTFOLDER="$2" 	&& shift && shift
			;;
		"-O") 	OUTPUTPATH="$2" 	&& shift && shift
			;;
		"-h"|"-?") 	echo $INFO  && echo "Command line parameters:" && echo "-t	Frontend Type, supported values: dvb-t (default), dvb-c" && echo "-f	Path to the 'channels.conf' file (colon delimited; defaults to $CHANNELS_CONF)" && echo "-c	Channel name" && echo "-s	Show all available channels" && echo "-l	Length of record (seconds)" && echo "-L	Length of record (minutes)" && echo "-t	Time (begin of record)" && echo "-n	File name (date, time, channel, and file extension will be added)" && echo "-N	File name (date, time, channel, and file extension won't be added)" && echo "-o	Output folder" && echo "-O	Output path (overrides output folder and file name)" && echo "-h -?	Help (display this)" && exit
			;;
		*)	echo "Aborting: Wrong parameter." && exit 1
			;;
	esac
done

if [ ! -s "$CHANNELS_CONF" ]
  then
	echo "Aborting: Channel configuration file $CHANNELS_CONF not found."
	exit 1
fi

case "$FRONTEND_TYPE" in
	"dvb-t")
		while IFS=':' read CHANNEL_NAME FREQUENCY IG1 IG2 IG3 IG4 IG5 IGN6 IGN7 IGN8 IGN9 IGN10 PROGRAM; do
			if [ -n "$LIST_CHANNELS" ]
			then
				echo "$CHANNEL_NAME"
			elif [ "$CHANNEL_NAME" = "$CHANNEL" ]
			then
				TUNING_OPTIONS="frequency=\"$FREQUENCY\":program=\"$PROGRAM\""
			fi
		done < "$CHANNELS_CONF"
		;;
	"dvb-c")
		while IFS=':' read CHANNEL_NAME FREQUENCY IG1 SYMBOL_RATE IG3 IG4 IG5 IGN6 PROGRAM; do
			if [ -n "$LIST_CHANNELS" ]
			then
				echo "$CHANNEL_NAME"
			elif [ "$CHANNEL_NAME" = "$CHANNEL" ]
			then
				TUNING_OPTIONS="frequency=\"$FREQUENCY\":srate=\"$SYMBOL_RATE\" --program=\"$PROGRAM\""
			fi
		done < "$CHANNELS_CONF"
		;;
	*)
		echo "Aborting: Frontend type not recognized."
		exit 1
		;;
esac

if [ -n "$LIST_CHANNELS" ]
then
	exit 0
fi

if [ -z "$TUNING_OPTIONS" ]
  then
	echo "Aborting: Unknown channel '$CHANNEL'."
	exit 1
fi

# Check if length set:
if [ -z "$LENGTH" ]
  then
	if [ -z "$MINUTES" ]
	  then
		echo "Aborting: No length indicated."
		exit 1
	  else
		LENGTH=$(( ${MINUTES} * 60 ))
	fi
fi

# Prepare output path:
if [ -z "$OUTPUTPATH" ]
  then
	# Check if folder set:
	if [ -z "$OUTPUTFOLDER" ]
	  then
		OUTPUTFOLDER="$PWD"
	  else
		OUTPUTFOLDER="${OUTPUTFOLDER%/}"
	fi
	
	# Check if name set:
	if [ -z "$NAME" ]
	  then
		NAME="record-$(date "+%Y-%m-%d_%H.%M")-${CHANNEL}"
	  else
		NAME="${NAME}-$(date "+%Y-%m-%d_%H.%M")-${CHANNEL}"
	fi
	
	if [ -z "$EXACTNAME" ]
	  then
		OUTPUTPATH="${OUTPUTFOLDER}/${NAME}.mpg"
	  else
		OUTPUTPATH="${OUTPUTFOLDER}/${EXACTNAME}"
	fi
fi

RECORD_COMMAND="cvlc $FRONTEND_TYPE://$TUNING_OPTIONS :run-time=\"$LENGTH\" --sout \"$OUTPUTPATH\" vlc://quit"

# Check if record time is set:
if [ -z "$RECTIME" ]
  then	# Start recorcing now…
	$($RECORD_COMMAND)
  else # Schedule recording…

	echo "$RECORD_COMMAND" | at "$RECTIME"
fi
