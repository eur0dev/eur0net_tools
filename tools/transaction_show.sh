#! /bin/bash


if [ "$1" = "" ];
then
	echo "Usage: $0 TRANSACTION-ID"
	exit 1
fi

TREE=/usr/local/euro/blockchain/

TRID="$1"

# Modify: Thu Feb  8 09:19:55 2018
##tran_id##|##tstamp##|##acct_id_out##|##acct_id_in##|##tran_value##|##acct_id_in_currency##|##acct_id_out_currency##|##exchange_rate_currency##|##curr_acct_id_out_balance##|##curr_acct_id_in_balance##|##node_id##|##exchange_id##|##net_id##|##spec_comm_value##|##vvt_comm_value##|##exchange_comm_value##|##node_comm_value##|##net_comm_value##|##prev_acct_id_out_balance##|##prev_acct_id_out_tran_id##|##prev_acct_id_out_time##|##prev_acct_id_in_balance##|##prev_acct_id_in_tran_id##|##prev_acct_id_in_time##|##tran_type##|##locked_value##|##locked_tran_id##|##hash_id##|
# cat block_chain.tl|grep tran_id|awk -F '|' '{for (i=1; i<=NF; i++) {split($i,f,"##"); print f[2]}}'

BCFILE=`awk -F '|' -v TRID=$TRID 'BEGIN {BCFILE="" } {if (TRID >= $1 && TRID <= $2) {BCFILE=$3;}} END {printf("%s", BCFILE);}' "$TREE/tran_id/tran_id.idx" 2>/dev/null`
if [ "$BCFILE" = "" ]
then
	echo "Could not find transaction $TRID"
	exit 1
fi

# /YYYY/MM/DD/HH
#YEAR="${BCFILE:0:4}"
#MONTH="${BCFILE:5:2}"
#DAY="${BCFILE:8:2}"
#HOUR="${BCFILE:11:2}"
#DATE="${YEAR}${MONTH}${DAY}${HOUR}"

grep "^$TRID|" "$TREE/tran_id/$BCFILE"|awk -F '|' -v BCFILE=$BCFILE '{
	printf("CONTAINING FILE: %s\n", BCFILE);
	printf("TRANSACTION ID: %s\n", $1);
	printf("TRANSACTION TIME: %s\n", $2);
	printf("ACCOUNT ID OUT: %s\n", $3);
	printf("ACCOUNT ID IN: %s\n", $4);
	printf("TRANSACTION VALUE: %s\n", $5);
	printf("FROM ACCOUNT ID CURRENCY: %s\n", $6);
	printf("TO ACCOUNT ID CURRENCY: %s\n", $7);
	printf("EXCHANGE RATE CURRENCY: %s\n", $8);
	printf("CURRENT ACCOUNT ID OUT BALANCE: %s\n", $9);
	printf("CURRENT ACCOUNT ID IN BALANCE: %s\n", $10);
	printf("NODE ID: %s\n", $11);
	printf("EXCHANGE ID: %s\n", $12);
	printf("NET ID: %s\n", $13);
	printf("SPECIAL COMMISSION VALUE: %s\n", $14);
	printf("VVT COMMISSION VALUE: %s\n", $15);
	printf("EXCHANGE COMMISSION VALUE: %s\n", $16);
	printf("NODE COMMISSION VALUE: %s\n", $17);
	printf("NET COMMISSION VALUE: %s\n", $18);
	printf("PREVIOUS ACCOUNT ID OUT BALANCE: %s\n", $19);
	printf("PREVIOUS ACCOUNT ID OUT TRANSACTION ID: %s\n", $20);
	printf("PREVIOUS ACCOUNT ID OUT TIME: %s\n", $21);
	printf("PREVIOUS ACCOUNT ID IN BALANCE: %s\n", $22);
	printf("PREVIOUS ACCOUNT ID IN TRANSACTION ID: %s\n", $23);
	printf("PREVIOUS ACCOUNT ID IN TIME: %s\n", $24);
	printf("TRANSACTION TYPE: %s\n", $25);
	printf("LOCKED VALUE: %s\n", $26);
	printf("LOCKED TRANSACTION ID: %s\n", $27);
	printf("HASH ID: %s\n", $28);
}'
