#!/bin/sh

IP_ADDRESS=$1

if [ -z "$1" ]
  then
    echo "Specify IP address of the HTTP server as argument"
	read -p "Press any key to exit ..."
	exit 1
fi

################################
# Become a Certificate Authority
################################
MY_CA_NAME=http_ca

OPENSSL_SUBJECT_INFO_CA="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=myCA"

# Generate a private root key
openssl genrsa -out $MY_CA_NAME.key 2048

# Self-sign a certificate.
openssl req -x509 -new -nodes -key $MY_CA_NAME.key -sha256 \
-days 3650 -out $MY_CA_NAME.crt -subj $OPENSSL_SUBJECT_INFO_CA

###############################
# Create CA-signed server cert
###############################

MY_SERVER_NAME=http_server

OPENSSL_SUBJECT_INFO_SERVER="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=$MY_SERVER_NAME"

# Generate a private key
openssl genrsa -out $MY_SERVER_NAME.key 2048

# Create the Certificate Signing Request (CSR).
# Make sure to set the "Common Name" field with MY_SERVER_NAME.
openssl req -new -key $MY_SERVER_NAME.key -out $MY_SERVER_NAME.csr \
-subj $OPENSSL_SUBJECT_INFO_SERVER

# Create a config file for the extensions
>$MY_SERVER_NAME.ext cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $MY_SERVER_NAME
DNS.2 = IP:$IP_ADDRESS
EOF

# Create the signed certificate
openssl x509 -req -in $MY_SERVER_NAME.csr -CA $MY_CA_NAME.crt \
-CAkey $MY_CA_NAME.key -CAcreateserial -out $MY_SERVER_NAME.crt \
-days 3650 -sha256 -extfile $MY_SERVER_NAME.ext

###############################
# Create CA-signed client cert
###############################

MY_CLIENT_NAME=http_client

OPENSSL_SUBJECT_INFO_CLIENT="/C=IN/ST=Karnataka/L=Bengaluru/O=CY/OU=Engineering/CN=$MY_CLIENT_NAME"

# Generate a private key
openssl genrsa -out $MY_CLIENT_NAME.key 2048

# Create the Certificate Signing Request (CSR).
openssl req -new -key $MY_CLIENT_NAME.key -out $MY_CLIENT_NAME.csr \
-subj $OPENSSL_SUBJECT_INFO_CLIENT

# Create the signed certificate
openssl x509 -req -in $MY_CLIENT_NAME.csr -CA $MY_CA_NAME.crt \
-CAkey $MY_CA_NAME.key -CAcreateserial -out $MY_CLIENT_NAME.crt \
-days 3650 -sha256

# Remove the intermediate files.
rm $MY_CA_NAME.srl $MY_SERVER_NAME.csr $MY_CLIENT_NAME.csr $MY_SERVER_NAME.ext

read -p "Press any key to exit ..."