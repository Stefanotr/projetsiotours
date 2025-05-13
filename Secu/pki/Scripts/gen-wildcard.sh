#!/bin/bash

CA_DIR="/etc/ssl/STS-Root-R2"
CA_CONF="$CA_DIR/openssl.cnf"
DEST_BASE="/home/toursadmin/STS-Root-R2/Client"

read -p "Nom de domaine sans etoile (ex: mana.lan) : " domaine
read -p "Pays [FR] : " C; C=${C:-FR}
read -p "Region [Centre-Val-de-Loire] : " ST; ST=${ST:-Centre-Val-de-Loire}
read -p "Ville [Tours] : " L; L=${L:-Tours}
read -p "Organisation [SportLudique] : " O; O=${O:-SportLudique}
read -p "Unite (OU) [IT-Departement] : " OU; OU=${OU:-IT-Departement}
read -p "Email (optionnel) [] : " EMAIL
read -p "Duree du certificat en jours [365] : " DAYS
DAYS=${DAYS:-365}

CN="*.$domaine"
SAN_LIST="DNS:$domaine, DNS:$CN"

# Recapitulatif
echo ""
echo "RECAPITULATIF"
echo "----------------------------"
echo "CN           : $CN"
echo "SAN          : $SAN_LIST"
echo "Organisation : $O"
echo "Unite (OU)   : $OU"
echo "Localite     : $L, $ST, $C"
[ -n "$EMAIL" ] && echo "Email        : $EMAIL"
echo "Duree        : $DAYS jours"
echo "Dossier      : $DEST_BASE/wildcard_$domaine"
echo ""

read -p "Confirmer la generation ? (o/n) : " confirm
[[ "$confirm" != "o" && "$confirm" != "O" ]] && { echo "Annule."; exit 1; }

# Chemins
dossier="$DEST_BASE/wildcard_$domaine"
mkdir -p "$dossier"
key="$dossier/privkey.key"
csr="$dossier/request.csr"
crt="$dossier/cert.crt"
extfile="$dossier/extfile.cnf"

# Generation cle privee ECC
openssl ecparam -name prime256v1 -genkey -noout -out "$key"

# CSR
subj="/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN"
[ -n "$EMAIL" ] && subj="$subj/emailAddress=$EMAIL"
openssl req -new -key "$key" -out "$csr" -subj "$subj"

# Extensions X.509 (sans CRL/OCSP)
cat > "$extfile" <<EOF
subjectAltName = $SAN_LIST
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

# Signature
openssl ca -batch -days "$DAYS" -in "$csr" -out "$crt" -config "$CA_CONF" -extfile "$extfile"

if [[ -f "$crt" ]]; then
    echo "Certificat wildcard signe -> $crt"
else
    echo "Erreur : certificat non genere."
fi