#! /bin/bash

if [ "$1" == "" ];
then
	echo "Usage: $0 YYYYMMDDHH"
	echo "Usage: $0 YYYYMMDD"
	echo "Usage: $0 YYYYMM"
	echo "Usage: $0 YYYY"
	exit 1
fi

TREE=/usr/local/euro/blockchain

DATE="$1"

YEAR="${DATE:0:4}"
MONTH="${DATE:4:2}"
DAY="${DATE:6:2}"
HOUR="${DATE:8:2}"

# Modify: Thu Feb  8 09:19:55 2018
##tran_id##|##tstamp##|##acct_id_out##|##acct_id_in##|##tran_value##|##acct_id_in_currency##|##acct_id_out_currency##|##exchange_rate_currency##|##curr_acct_id_out_balance##|##curr_acct_id_in_balance##|##node_id##|##exchange_id##|##net_id##|##spec_comm_value##|##vvt_comm_value##|##exchange_comm_value##|##node_comm_value##|##net_comm_value##|##prev_acct_id_out_balance##|##prev_acct_id_out_tran_id##|##prev_acct_id_out_time##|##prev_acct_id_in_balance##|##prev_acct_id_in_tran_id##|##prev_acct_id_in_time##|##tran_type##|##locked_value##|##locked_tran_id##|##hash_id##|

export DIR=$YEAR${YEAR:+/}$MONTH${MONTH:+/}$DAY${DAY:+/}$HOUR
echo "DIR=$DIR"

idx=0
DATA1=
DATA2=

function block_check()
{
	local FILE=$1
	local DATE1=$2
	local DATA2_1
	local HASH_1
	local idx=0
	local HASH
	local NEWHASH
	local STATUS=-1

	echo "Opening file $FILE"
	if [ ! -f "$FILE" ]
	then
		echo "$FILE not found"
		return 255
	fi
	for i in `cat "$FILE" 2>/dev/null`
	do
		STATUS=0
		let idx=$idx+1
		if [ $idx -gt 1 ]
		then
			DATA1=$DATA2
		fi
		eval `echo "$i"|awk -F '|' '{DATA=""; for(ii=1;ii<NF-1;ii++) {DATA=DATA""$ii"|" }; printf("export DATA2=\"%s\";",DATA); printf("export HASH=%s;", $(NF-1));}'`
		if [ $idx -eq 1 ]
		then
			DATE2=`date -d "${DATE1:0:8} ${DATE1:8:2} - 1 hour ago" +%Y%m%d%H`
			Y1="${DATE2:0:4}"
			M1="${DATE2:4:2}"
			D1="${DATE2:6:2}"
			H1="${DATE2:8:2}"
			export DIR1=$Y1${Y1:+/}$M1${M1:+/}$D1${D1:+/}$H1
			eval `tail -n1 "$TREE/tran_id/$DIR1/$DATE2.bc" 2>/dev/null|awk -F '|' '{DATA=""; for(ii=1;ii<NF-1;ii++) {DATA=DATA""$ii"|" }; printf("export DATA2_1=\"%s\";",DATA); printf("export HASH_1=%s;", $(NF-1));}'`
			if [ "$DATA2_1" = "" ] || [ "$HASH_1" = "" ]
			then
				echo "Searching for previous transaction in $TREE/tran_id/$DIR1/$DATE2.bc"
				echo $"Could not find previous transaction. Checking if it is first..."
				DATA1="$DATA2"
			else
				DATA1="$DATA2_1"
			fi
		fi
		NEWHASH=`echo "${DATA1}${DATA2}"|sha256sum|awk '{print $1}'`
		if [ "$HASH" != "$NEWHASH" ]
		then
			echo "LINE: $idx, HASH ERROR: EXPECTED ($NEWHASH), FOUND ($HASH)"
			STATUS=1
			break
		fi
	done
	return $STATUS
}

function print_status()
{
	local DATE=$1
	local STATUS=$2

	case $STATUS in
	0)
		echo "DATE=$DATE: ALL HASHES MATCH"
		;;
	1)
		echo "DATE=$DATE: ERROR"
		;;
	255)
		echo "DATE=$DATE: NOT FOUND"
		;;
	-1)
		echo "DATE=$DATE: UNKNOWN ERROR"
		;;
	esac
}


if [ "$YEAR" != "" -a "$MONTH" != "" -a "$DAY" != "" -a "$HOUR" != "" ]
then
	# HOUR
	block_check "$TREE/tran_id/$DIR/$DATE.bc" $DATE
	STATUS=$?
	print_status $DATE $STATUS
elif [ "$YEAR" != "" -a "$MONTH" != "" -a "$DAY" != "" ]
then
	# ALL HOURS
	for h in `ls -w1 "$TREE/tran_id/$DIR/" 2>/dev/null`
	do
		block_check "$TREE/tran_id/$DIR/$h/$DATE${h}.bc" $DATE${h}
		STATUS=$?
		print_status "$DATE${h}" $STATUS
	done
elif [ "$YEAR" != "" -a "$MONTH" != "" ]
then
	# ALL DAYS
	for d in `ls -w1 "$TREE/tran_id/$DIR/" 2>/dev/null`
	do
		# ALL HOURS
		for h in `ls -w1 "$TREE/tran_id/$DIR/$d" 2>/dev/null`
		do
			block_check "$TREE/tran_id/$DIR/$d/$h/$DATE${d}${h}.bc" $DATE${d}${h}
			STATUS=$?
			print_status "$DATE${d}${h}" $STATUS
		done
	done
elif [ "$YEAR" != "" ]
then
	# ALL MONTHS
	for m in `ls -w1 "$TREE/tran_id/$DIR/" 2>/dev/null`
	do
		# ALL DAYS
		for d in `ls -w1 "$TREE/tran_id/$DIR/$m" 2>/dev/null`
		do
			# ALL HOURS
			for h in `ls -w1 "$TREE/tran_id/$DIR/$m/$d" 2>/dev/null`
			do
				block_check "$TREE/tran_id/$DIR/$m/$d/$h/$DATE${m}${d}${h}.bc" $DATE${m}${d}${h}
				STATUS=$?
				print_status "$DATE${m}${d}${h}" $STATUS
			done
		done
	done
fi
