E0 network provides a complete set of tools
-------------------------------------------
E0 provides tools to allow easy block-chain validation, navigation, and viewing.

All tools are in Linux shell script which makes them open-source, completely transparent for everybody.

The shell script tools are distributed within compressed file called: e0.shell.tgz

To use just download the file and run under any version of Linux: gzip -d e0.shell.tgz

This will expand to several shell executable files. In addition, make sure that you have the expanded block-chain tree under the directory /usr/local/euro


Account Balance Tools
---------------------
./account_balance.sh account-id - running this program will return the account balance with the following format: ACCOUNT-ID|BALANCE
Usage: ./account_balance.sh ACCOUNT-ID

./account_tran.sh - running this program will return the full account debit and credit block-chain record history and check the account balance based on credit and debit records.
Usage: ./account_tran.sh ACCOUNT-ID

./transaction_show.sh - running this program will display full transaction information for the selected transaction id
Usage: ./transaction_show.sh TRANSACTION-ID

./account_tran_detail.sh – running this program will return the full account debit and credit block-chain record history and check the account balance based on credit and debit records.
Usage: ./account_tran_detail.sh ACCOUNT-ID


Transaction Validation Tools
----------------------------
./master_hash_check.sh - running the program will check the master hash for defined block-chain tree file.
Usage: ./master_hash_check.sh YYYYMMDDHH

./block_check.sh - running the program will validate the block-chain file for transaction sequence consistency and hash sequence consistency. The command can validate the block-chain for one hour or one day based on the input parameter format.
Usage: ./block_check.sh YYYYMMDDHH


Block-Chain management Tools
----------------------------
./bctree_extract_tgz.sh - running this program will extract the block-chain tree files form the source directory into the destination directory.
Usage: ./bctree_extract_tgz.sh SOURCE-TGZ-DIRECTORY DESTINATION-DIRECTORY
# eur0net_tools
