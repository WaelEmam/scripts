# scripts Description

## Create_keytab.exp
This is an Expect script that takes three variables UserID, Password and REALM to create a keytab for the specified UserID.
To be able to use this script, you will need to have expect package installed on your machine.
```
./create_keytab.exp testuser password test.example.com
spawn ktutil
addent -password -p testuser@test.example.com -k 1 -e aes256-cts
ktutil:  addent -password -p testuser@test.example.com -k 1 -e aes256-cts
Password for testuser@test.example.com:
ktutil:  addent -password -p testuser@test.example.com -k 1 -e aes128-cts
Password for testuser@test.example.com:
ktutil:  addent -password -p testuser@test.example.com -k 1 -e arcfour-hmac
Password for testuser@test.example.com:
ktutil:  addent -password -p testuser@test.example.com -k 1 -e des-cbc-md5
Password for testuser@test.example.com:
ktutil:  addent -password -p testuser@test.example.com -k 1 -e des3-cbc-sha1
Password for testuser@test.example.com:
ktutil:  wkt testuser.keytab

klist -ket testuser.keytab
Keytab name: FILE:testuser.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   1 07/04/2018 14:31:51 testuser@test.example.com (aes256-cts-hmac-sha1-96)
   1 07/04/2018 14:31:51 testuser@test.example.com (aes128-cts-hmac-sha1-96)
   1 07/04/2018 14:31:51 testuser@test.example.com (arcfour-hmac)
   1 07/04/2018 14:31:51 testuser@test.example.com (des-cbc-md5)
   1 07/04/2018 14:31:51 testuser@test.example.com (des3-cbc-sha1)
```

## hive_db_mover.sh

Occasionally, we got a request from app teams to move their HIVE DB from one location to another. So far Hive doesn't support export and import of databases, but its supports tables export/import. In this script I looped though all the tables of a given database, exported them to another location "/tmp", then imported them to a new database in a new location.
##### Note: DB is moved within the same cluster

