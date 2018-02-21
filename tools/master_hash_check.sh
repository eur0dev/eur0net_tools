#! /bin/bash  +x

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

KEY=/usr/local/euro/mykeys
TREE=/usr/local/euro/blockchain/tran_id/

if [ "$1" == "" ];
then
 echo "Usage: $0 YYYYMMDDHH"
 exit 1
fi

DATE="$1"
if [ "$1" == "" ];
then
        sleep 1
        DATE="`date +%Y%m%d%H --date="-1 hour"`"
fi

YEAR="${DATE:0:4}"
MONTH="${DATE:4:2}"
DAY="${DATE:6:2}"
HOUR="${DATE:8:2}"

L=$TREE$YEAR/$MONTH/$DAY/$HOUR/hash_web.lst
LIST=$TREE$YEAR/$MONTH/$DAY/$HOUR/hash_db.lst
BCHASH=$TREE$YEAR/$MONTH/$DAY/$HOUR/hash_bc.lst
MASTER=$TREE$YEAR/$MONTH/$DAY/$HOUR/$DATE.mh
SIGFILE=$TREE$YEAR/$MONTH/$DAY/$HOUR/$DATE.sig

/usr/local/bin/curl "http://127.0.0.1/cgi-bin/euro.cgi?run=gen&cmd=3&dat=$DATE" 2>/dev/null | cut -f1 -d'|' | grep -e "[0-9a-f]" > $L 2>/dev/null

cat $L | cut -f1 -d'|' | grep -e "[0-9a-f]" > $LIST
echo $LIST "(RECORDS: "`cat $LIST | wc -l`")"
DMASTER=`cat $LIST | /usr/bin/openssl sha256 | cut -c10- `
echo $DMASTER
echo "---------------------------"

cat $TREE$YEAR/$MONTH/$DAY/$HOUR/$DATE.bc | cut -f28 -d'|' | grep -e "[0-9a-f]" > $BCHASH
LC=`cat $BCHASH | wc -l`
echo $BCHASH "(RECORDS: "$LC")"
FMASTER=`cat $BCHASH | /usr/bin/openssl sha256 |  cut -c10- `
echo $FMASTER
echo "---------------------------"

HW=`cat $L | wc -l `
HD=`cat $LIST | wc -l `
HB=`cat $BCHASH | wc -l `
echo "MASTER HASH TIME:"`date +"%Y-%m-%d %H:%M:%S PER:$DATE HW:$HW HD:$HD HB:$HB"` | tee -a /tmp/euro.log

[ "$FMASTER" = "$DMASTER" -a $LC -gt 0 ] && echo $FMASTER > $MASTER && echo "M.HASH (TRUE): $MASTER"
[ "$FMASTER" = "$DMASTER" -a $LC -gt 0 ] || echo "M.HASH (FALSE)"


MYCN="$(openssl x509 -noout -subject -in $KEY/node.pem | sed -n '/^subject/s/^.*CN=//p')"

/usr/bin/openssl dgst -sha256 -sign "$KEY/node.pem" -out /tmp/${MYCN}.sha256 $MASTER

TSIG="$(base64 -w0 /tmp/${MYCN}.sha256)"

echo "${MYCN}|$TSIG" >>  $SIGFILE
rm /tmp/${MYCN}.sha256


# check signature with:
# openssl rsa -in node.pem -pubout > public.pem
# /usr/bin/openssl dgst -sha256 -verify "$KEY/public.pem"  -signature $MASTER.${MYCN}.sha256 $MASTER
