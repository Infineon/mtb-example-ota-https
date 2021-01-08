#!/bin/sh

IP_ADDRESS=$1

if [ -z "$1" ]
  then
    echo "Specify IP address of HTTP server as argument"
	read -p "Press any key to exit ..."
	exit 1
fi

################################
# Become a Certificate Authority
################################

OPENSSL_SUBJECT_INFO_CA="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=myCA"

# Generate a private root key
openssl genrsa -out rootCA.key 2048

# Self-sign a certificate.
openssl req -x509 -new -nodes -key rootCA.key -sha256 \
-days 3650 -out rootCA.crt -subj $OPENSSL_SUBJECT_INFO_CA

###############################
# Create CA-signed server cert
###############################

MY_DOMAIN_NAME=mysecurehttpserver.local

OPENSSL_SUBJECT_INFO_SERVER="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=$MY_DOMAIN_NAME"

# Generate a private key
openssl genrsa -out $MY_DOMAIN_NAME.key 2048

# Create the Certificate Signing Request (CSR).
# Make sure to set the "Common Name" field with MY_DOMAIN_NAME.
openssl req -new -key $MY_DOMAIN_NAME.key -out $MY_DOMAIN_NAME.csr \
-subj $OPENSSL_SUBJECT_INFO_SERVER

# Create a config file for the extensions
>$MY_DOMAIN_NAME.ext cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $MY_DOMAIN_NAME
DNS.2 = $IP_ADDRESS
EOF

# Create the signed certificate
openssl x509 -req -in $MY_DOMAIN_NAME.csr -CA rootCA.crt \
-CAkey rootCA.key -CAcreateserial -out $MY_DOMAIN_NAME.crt \
-days 3650 -sha256 -extfile $MY_DOMAIN_NAME.ext

# Create ssl key for mongoose using server certificate ($MY_DOMAIN_NAME.crt) and
# server private key ($MY_DOMAIN_NAME.key)
cat $MY_DOMAIN_NAME.key > server.pem
cat $MY_DOMAIN_NAME.crt >> server.pem

###############################
# Create CA-signed client cert
###############################

OPENSSL_SUBJECT_INFO_CLIENT="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=Client"

# Generate a private key
openssl genrsa -out client.key 2048

# Create the Certificate Signing Request (CSR).
openssl req -new -key client.key -out client.csr \
-subj $OPENSSL_SUBJECT_INFO_CLIENT

# Create the signed certificate
openssl x509 -req -in client.csr -CA rootCA.crt \
-CAkey rootCA.key -CAcreateserial -out client.crt \
-days 3650 -sha256

# Remove the intermediate files.
rm rootCA.srl $MY_DOMAIN_NAME.csr $MY_DOMAIN_NAME.ext $MY_DOMAIN_NAME.key $MY_DOMAIN_NAME.crt client.csr

read -p "Press any key to exit ..."