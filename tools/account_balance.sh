#! /bin/bash

if [ "$1" == "" ];
then
	echo "Usage: $0 ACCOUNT-ID"
	exit 1
fi

TREE=/usr/local/euro/blockchain/bal/

D1="${1:0:3}"
D2="${1:3:3}"

#Modify: Thu Feb  8 09:19:55 2018
# ##tran_id##|##tstamp##|##acct_id_out##|##acct_id_in##|##tran_value##|##acct_id_in_currency##|##acct_id_out_currency##|##exchange_rate_currency##|##curr_acct_id_out_balance##|##curr_acct_id_in_balance##|##node_id##|##exchange_id##|##net_id##|##spec_comm_value##|##vvt_comm_value##|##exchange_comm_value##|##node_comm_value##|##net_comm_value##|##prev_acct_id_out_balance##|##prev_acct_id_out_tran_id##|##prev_acct_id_out_time##|##prev_acct_id_in_balance##|##prev_acct_id_in_tran_id##|##prev_acct_id_in_time##|##tran_type##|##locked_value##|##locked_tran_id##|##hash_id##|

TRAN_ID_OUT=
TRAN_ID_IN=
ARR_IN=
ARR_OUT=
VALS_IN=
VALS_OUT=
VALS=

if [ -f "$TREE/$D1/$D2/$1.in.bal" ]
then
	VALS_IN=`cat "$TREE/$D1/$D2/$1.in.bal" 2>/dev/null`
	ARR_IN=(${VALS_IN//|/ })
fi

TRAN_ID_IN=${ARR_IN[0]:-0}
BALANCE=${ARR_IN[9]:-0.0000}

if [ -f "$TREE/$D1/$D2/$1.out.bal" ]
then
	VALS_OUT=`cat "$TREE/$D1/$D2/$1.out.bal" 2>/dev/null`
	ARR_OUT=(${VALS_OUT//|/ })
fi

TRAN_ID_OUT=${ARR_OUT[0]:-0}
LOCKED_VALUE=${ARR_OUT[25]:-0.0000}

if [ "$[(TRAN_ID_OUT)]" -gt "$[(TRAN_ID_IN)]" ]
then
	BALANCE=${ARR_OUT[8]}
fi

if [ "${BALANCE}" != "" ]
then
	echo -n "$1|${BALANCE}"
	if [ "$LOCKED_VALUE" != "" ] && [ "$LOCKED_VALUE" != "0.0000" ]
	then
		echo "|${LOCKED_VALUE}"
	else
		echo ""
	fi
else
	echo "0.0000"
fi

# from database
if [ -f "$TREE/$D1/$D2/$1.bal" ]
then
	VALS=`cat "$TREE/$D1/$D2/$1.bal" 2>/dev/null`
	# ACCTID|CREDIT|DEBIT|LOCKED|DATE
	VALS=(${VALS//|/ })
	DB_CREDIT=${VALS[1]:-0.0000}
	DB_DEBIT=${VALS[2]:-0.0000}
	DB_LOCKED=${VALS[3]:-0.0000}
	DB_DATE=${VALS[4]}
	DB_BALANCE=`echo "scale=4;($DB_CREDIT)-($DB_DEBIT)"|bc -l`
	if [ "$DB_BALANCE" != "" ]
	then
		[ "${DB_BALANCE:0:2}" = "-." ] && DB_BALANCE="-0.${DB_BALANCE:2}"
		[ "${DB_BALANCE:0:1}" = "." ] && DB_BALANCE="0${DB_BALANCE:0}"
	fi
	if [ "${BALANCE}" != "${DB_BALANCE}" ]
	then
		echo "BALANCE ERROR: (BALANCE=$BALANCE, DB_BALANCE=$DB_BALANCE, DATE=$DB_DATE)"
	fi
fi

