#! /bin/bash

if [ "$1" == "" ];
then
	echo "Usage: $0 ACCOUNT-ID"
	exit 1
fi

TREE=/usr/local/euro/blockchain/
SCRIPT_PATH=`dirname $0`
CREDIT=0.0000
DEBIT=0.0000
BALANCE=0.0000
ACCOUNT_BALANCE=0.0000

cd $SCRIPT_PATH && SCRIPT_PATH=`pwd`

D1="${1:0:3}"
D2="${1:3:3}"
#Modify: Thu Feb  8 09:19:55 2018
##tran_id##|##tstamp##|##acct_id_out##|##acct_id_in##|##tran_value##|##acct_id_in_currency##|##acct_id_out_currency##|##exchange_rate_currency##|##curr_acct_id_out_balance##|##curr_acct_id_in_balance##|##node_id##|##exchange_id##|##net_id##|##spec_comm_value##|##vvt_comm_value##|##exchange_comm_value##|##node_comm_value##|##net_comm_value##|##prev_acct_id_out_balance##|##prev_acct_id_out_tran_id##|##prev_acct_id_out_time##|##prev_acct_id_in_balance##|##prev_acct_id_in_tran_id##|##prev_acct_id_in_time##|##tran_type##|##locked_value##|##locked_tran_id##|##hash_id##|

echo "Credit Transactions:"
VAL="0.0000|0.0000"
if [ -f "$TREE/acct_id_in/$D1/$D2/$1.bc" ]
then
	cat "$TREE/acct_id_in/$D1/$D2/$1.bc"
	VAL=`cat "$TREE/acct_id_in/$D1/$D2/$1.bc"|awk -F '|' 'BEGIN {sum=0;lsum=0;} {sum+=$5-$14-$15-$16-$17-$18;lsum=$26} END {printf("%.4f|%.4f\n", sum, lsum)}'`
fi
VAL_ARR=(${VAL//|/ })
CREDIT=${VAL_ARR[0]:-0.0000}
LOCKED_VALUE=${VAL_ARR[1]:-0.0000}
echo -en "Total: $CREDIT"
if [ "$LOCKED_VALUE" != "" ] && [ "$LOCKED_VALUE" != "0.0000" ]
then
	echo -e ", Locked: $LOCKED_VALUE\n\n"
else
	echo -e "\n\n"
fi

echo "Debit Transactions:"
VAL="0.0000|0.0000"
if [ -f "$TREE/acct_id_out/$D1/$D2/$1.bc" ]
then
	cat "$TREE/acct_id_out/$D1/$D2/$1.bc"
	VAL=`cat "$TREE/acct_id_out/$D1/$D2/$1.bc"|awk -F '|' 'BEGIN {sum=0; lsum=0;} {sum+=$5; lsum=$26} END {printf("%.4f|%.4f\n", sum, lsum);}'`
fi
VAL_ARR=(${VAL//|/ })
DEBIT=${VAL_ARR[0]:-0.0000}
LOCKED_VALUE=${VAL_ARR[1]:-0.0000}
printf "Total: %.4f" $DEBIT
if [ "$LOCKED_VALUE" != "" ] && [ "$LOCKED_VALUE" != "0.0000" ]
then
	echo -e ", Locked: $LOCKED_VALUE\n\n"
else
	echo -e "\n\n"
fi

BALANCE=`echo "scale=4; $CREDIT-$DEBIT"|bc -l`
printf "Balance: %.4f" $BALANCE
if [ "$LOCKED_VALUE" != "" ] && [ "$LOCKED_VALUE" != "0.0000" ]
then
	echo -e ", Locked: $LOCKED_VALUE\n"
else
	echo -e "\n"
fi

BALANCE_VALS=`$SCRIPT_PATH/account_balance.sh $1`
ACCOUNT_ARR=(${BALANCE_VALS//|/ })
ACCOUNT_BALANCE=${ACCOUNT_ARR[1]:-0.0000}
LOCKED_BALANCE=${ACCOUNT_ARR[2]:-0.0000}
RESULT=`echo "define abs(i) { if (i < 0) return (-i); return (i);}; val=($BALANCE)-($ACCOUNT_BALANCE);abs(val)<=0.0000"|bc`
if [ "$RESULT" = 1 ]
then
	echo "Balance Check: TRUE"
else
	echo "Balance Check: FALSE ($ACCOUNT_BALANCE)"
fi
