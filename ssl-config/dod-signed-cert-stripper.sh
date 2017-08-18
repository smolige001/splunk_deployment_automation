#!/bin/bash
#
# ===========================================================
# Purpose:	This script will rip the server certificate and cacert out of the .txt file generated by the DOD webpage
#           It will convert the cacaert from p7b to .pem
#           three files will be produced: hostname001.dod.mil.cer.txt-server.pem, hostname001.dod.mil.cer.txt-cacert.pem, hostname001.dod.mil.cer.txt-server.pem
#           hostname001.dod.mil.cer.txt_only-cert.cert <- which gets deleted
#           tar the two .pem files and private key file into one bundle with the hostname ex: tar cvf hostname001.dod.mil.keysandcerts.tar *.pem *key
# Privileges:	Must have openssl in path, ownership of certificate txt file
# Author:	Anthony Tellez
#
# Notes:	Only tested on RHEL7, OSX grep does not have perl support (I believe)
#
#
# Revision:	Last change: 05/23/2017 by AT :: Built and tested
# ===========================================================
#
name=${1}
grep -Pzo '(?s)-{5}BEGIN (CERTIFICATE)-{5}.*?-{5}END \1-{5}'  ${1} > ${name}_only-cert.cert
cat ${name}_only-cert.cert |awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "'${name}'-server" n ".cert"}'
mv ${name}-server1.cert ${name}-cacert.p7b
mv ${name}-server.cert ${name}-server.pem
rm -fr ${name}_only-cert.cert
openssl pkcs7 -in ${name}-cacert.p7b -print_certs -out ${name}-cacert.pem
echo "############################## validating server certificate ###########################"
openssl x509 -in ${name}-server.pem -text -noout
echo "############################## validating ca certificate ###########################"
openssl x509 -in ${name}-cacert.pem -text -noout