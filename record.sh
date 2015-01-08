#!/bin/bash

# DE: Dieses Script schmeißt die DVB-T-Aufnahme mithilfe des VLC Media Players an:

INFO="This script will start DVB-T recording via VLC Media Player."


# Check parameters:
while [ ! -z "$1" ]
  do
	case "$1" in
		"-c") 	CHANNEL="$2" 		&& shift && shift
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
		"-h"|"-?") 	echo $INFO  && echo "Command line parameters:" && echo "-c	Channel name" && echo "-l	Length of record (seconds)" && echo "-L	Length of record (minutes)" && echo "-t	Time (begin of record)" && echo "-n	File name (date, time, channel, and file extension will be added)" && echo "-N	File name (date, time, channel, and file extension won't be added)" && echo "-o	Output folder" && echo "-O	Output path (overrides output folder and file name)" && echo "-h -?	Help (display this)" && exit
			;;
		*)	echo "Aborting: Wrong parameter." && exit 1
			;;
	esac
done

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

# Set values for TV channels:
case "$CHANNEL" in
	"arte")			FREQUENCY="482000000"
				PROGRAM="2"
				;;
	"phoenix")		FREQUENCY="482000000"
				PROGRAM="3"
				;;
	"zdfinfo")		FREQUENCY="562000000"
				PROGRAM="516"
				;;
	"3sat")			FREQUENCY="562000000"
				PROGRAM="515"
				;;
	"ard"|"daserste")	FREQUENCY="482000000"
				PROGRAM="160"
				;;
	"zdf")			FREQUENCY="562000000"
				PROGRAM="514"
				;;
	"ndr")			FREQUENCY="482000000"
				PROGRAM="161"
				;;
	"wdr")			FREQUENCY="538000000"
				PROGRAM="262"
				;;
	"mdr")			FREQUENCY="538000000"
				PROGRAM="100"
				;;
	"hr")			FREQUENCY="538000000"
				PROGRAM="65"
				;;
	"zdfneo"|"neo"|"kika")	FREQUENCY="562000000"
				PROGRAM="517"
				;;
	"sat1") 		FREQUENCY="698000000"
				PROGRAM="16408"
				;;
	"rtl")			FREQUENCY="642000000"
				PROGRAM="16405"
				;;
	"pro7"|"prosieben")	FREQUENCY="698000000"
				PROGRAM="16403"
				;;
	"vox")			FREQUENCY="642000000"
				PROGRAM="16418"
				;;
	"rtl2")			FREQUENCY="642000000"
				PROGRAM="16406"
				;;
	"kabel"|"kabel1")	FREQUENCY="698000000"
				PROGRAM="16394"
				;;
	"srtl")			FREQUENCY="642000000"
				PROGRAM="16407"
				;;
	*)			echo "Aborting: Channel not recognized."
				exit 1
				;;
esac

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

# Check if record time is set:
if [ -z "$RECTIME" ]
  then	# Start recorcing now…
	cvlc dvb-t://frequency="$FREQUENCY" :program="$PROGRAM" :run-time="$LENGTH" --sout "$OUTPUTPATH" vlc://quit
  else # Schedule recording…

	echo "cvlc dvb-t://frequency=$FREQUENCY :program=$PROGRAM :run-time=$LENGTH --sout \"$OUTPUTPATH\" vlc://quit" | at "$RECTIME"
fi
