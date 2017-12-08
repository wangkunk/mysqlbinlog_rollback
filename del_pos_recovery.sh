#!/bin/bash
# File Name   : del_pos_recovery.sh
# Author      : wang
# Description : delete recover according to start position and stop postion.

Usage() {
cat << EOF
mysql_delete_recovery
OPTIONS:
   -b      binlog name
   -p      position
   -e      endposition
   -d      database name
   -t      table name

For secrity: This scripts check the full need arguments
EOF
}

while getopts ":b:p:e:d:t:" opt; do
  case $opt in
    b)
      logname=${OPTARG}
      ;;
    p)
      position=${OPTARG}
      ;;
    e)
      endposition=${OPTARG}
      ;;
    d)
      db=${OPTARG}
      ;;
    t)
      table=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      Usage
      exit 1
      ;;
  esac
done

if [ $# != 10 ] ; then
    Usage
    exit 1;
fi

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/mysql/bin
export PATH

user=root
pwd='yourpass'
tmpfile=/tmp/del_recovery_$table.sql
mysqlbinlog --no-defaults -vv --base64-output=DECODE-ROWS --start-position=''$position'' --stop-position=''$endposition'' $logname |sed -n '/### DELETE FROM `'${db}'`.`'${table}'`/,/COMMIT/p' | \
sed -n '/###/p'    | \
sed 's/### //g;s/\/\*.*/,/g;s/DELETE FROM/INSERT INTO/g;s/WHERE/SELECT/g;'   > $tmpfile
n=0;
for i in `mysql -u$user -p$pwd --skip-column-names --silent -e "desc $db.$table" |awk '$0=$1'`;
do
        ((n++));
done
sed -i -r "s/(@$n.*),/\1;/g" $tmpfile
sed -i 's/@[1-9].*=//g' $tmpfile
sed -i 's/@[1-9][0-9]=//g' $tmpfile
