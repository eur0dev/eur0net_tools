#! /bin/bash

TREE=/usr/local/euro/blockchain/tran_id

if [ "$#" -lt 2 ]
then
	echo "Usage: $0 tgz_dir [tran_id_dir]"
	echo "Default tran_id directory: $TREE"
	echo "Example: ./ /usr/local/euro/blockchain/tran_id"
	exit 0
fi

FILES_DIR="$1"
TRAN_DIR="$2"

cd "$FILES_DIR"
for i in `ls -w1 blockchain_*.bc.tar blockchain_*.bc.tgz`
do
	DATE="${i:11}"
	if [ "${i:(-3)}" = "tgz" ]
	then
		DATE="${DATE%%.bc.tgz}"
	elif [ "${i:(-3)}" = "tar" ]
	then
		DATE="${DATE%%.bc.tar}"
	fi
	Y="${DATE:0:4}"
	M="${DATE:4:2}"
	D="${DATE:6:2}"
	H="${DATE:8:2}"
	[ "${Y}" != "" ] && [ "${Y}" -lt 2018 ] && continue
	[ "${M}" != "" ] && [ "${M}" -lt 1 -o "${M}" -gt 12 ] && continue
	[ "${D}" != "" ] && [ "${D}" -lt 1 -o "${D}" -gt 31 ] && continue
	[ "${H}" != "" ] && [ "${H}" -lt 0 -o "${H}" -gt 23 ] && continue

	D1="${Y}${M}${D}${H}"
	[ "$DATE" != "$D1" ] && continue
	echo "Extracting $i to $TRAN_DIR"
	if [ "${i:(-3)}" = "tgz" ]
	then
		tar xfz "$i" -C "$TRAN_DIR"
	elif [ "${i:(-3)}" = "tar" ]
	then
		tar -xOf "$i"|tar xzf - -C "$TRAN_DIR"
	fi
done
