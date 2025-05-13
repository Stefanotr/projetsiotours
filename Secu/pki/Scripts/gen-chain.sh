#!/bin/bash

CA_DIR="/etc/ssl/STS-Root-R2"
CA_CONF="$CA_DIR/openssl.cnf"
DEST_BASE="/home/toursadmin/STS-Root-R2/Client"

read -p "Nom de l'autorite intermediaire (ex: intermediate.mana.lan) : " domaine
read -p "Pays [FR] : " C; C=${C:-FR}
read -p "Region [Centre-Val-de-Loire] : " ST; ST=${ST:-Centre-Val-de-Loire}
read -p "Ville [Tours] : " L; L=${L:-Tours}
read -p "Organisation [SportLudique] : " O; O=${O:-SportLudique}
read -p "Unite (OU) [IT-Departement] : " OU; OU=${OU:-IT-Departement}
read -p "Email (optionnel) [] : " EMAIL
read -p "Duree du certificat en jours [1825] : " DAYS
DAYS=${DAYS:-1825}

CN="$domaine"
dossier="$DEST_BASE/intermediate_$domaine"
mkdir -p "$dossier"
key="$dossier/privkey.key"
csr="$dossier/request.csr"
crt="$dossier/cert.crt"

# Recapitulatif
echo ""
echo "RECAPITULATIF"
echo "----------------------------"
echo "CN           : $CN"
echo "Organisation : $O"
echo "Unite (OU)   : $OU"
echo "Localite     : $L, $ST, $C"
[ -n "$EMAIL" ] && echo "Email        : $EMAIL"
echo "Duree        : $DAYS jours"
echo "Dossier      : $dossier"
echo ""

read -p "Confirmer la generation de l'autorite intermediaire ? (o/n) : " confirm
[[ "$confirm" != "o" && "$confirm" != "O" ]] && { echo "Annule."; exit 1; }

# Generation de la cle ECC
openssl ecparam -name prime256v1 -genkey -noout -out "$key"

# Generation CSR
subj="/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN"
[ -n "$EMAIL" ] && subj="$subj/emailAddress=$EMAIL"
openssl req -new -key "$key" -out "$csr" -subj "$subj"

# Signature avec extensions v3_ca definies dans openssl.cnf
openssl ca -batch -days "$DAYS" -in "$csr" -out "$crt" -config "$CA_CONF" -extensions v3_ca

if [[ -f "$crt" ]]; then
    echo "Certificat d'autorite intermediaire signe -> $crt"
else
    echo "Erreur : certificat non genere."
fi
