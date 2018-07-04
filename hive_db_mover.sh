#!/bin/bash
DB=$1
LOC=$2

usage(){
        echo "Usage: ./hive_db_mover.sh db_to_be_moved new_location"
        exit 1
}

if [ $# -eq 0 ]
  then
    usage
fi

# Export DB
tables=$(beeline --silent=true --fastConnect=true -e  "use $DB; show tables;"| awk '{print $2}'| grep -v tab_name)
echo $tables

for table in $tables
do
   beeline --silent=true --fastConnect=true -e "use $DB; export table $table to '/tmp/$DB.db/$table'"
   hadoop fs -ls /tmp/$DB.db
done

#Delete old DB & Create new one

beeline --silent=true --fastConnect=true -e "DROP DATABASE IF EXISTS $DB CASCADE; create database $DB location '$LOC/$DB.db'"


# Import
tables2=$(hadoop fs -ls /tmp/$DB.db| awk '{print $8}'| awk -F/ '{print $4}')
for table in $tables2
do

   beeline --silent=true --fastConnect=true -e "use $DB; import table $table from '/tmp/$DB.db/$table'"
done

beeline --silent=true --fastConnect=true -e "use $DB; describe database extended $DB"

