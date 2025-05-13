#!/bin/bash

CA_DIR="/etc/ssl/STS-Root-R2"
CA_CONF="$CA_DIR/openssl.cnf"
DEST_BASE="/home/toursadmin/STS-Root-R2/Client"

read -p "Nom de domaine (ex: serveur.mana.lan) : " domaine
read -p "Pays [FR] : " C; C=${C:-FR}
read -p "Région [Centre-Val-de-Loire] : " ST; ST=${ST:-Centre-Val-de-Loire}
read -p "Ville [Tours] : " L; L=${L:-Tours}
read -p "Organisation [SportLudique] : " O; O=${O:-SportLudique}
read -p "Unité (OU) [IT-Departement] : " OU; OU=${OU:-IT-Departement}
read -p "Email (optionnel) [] : " EMAIL
read -p "Durée du certificat en jours [365] : " DAYS
DAYS=${DAYS:-365}

CN="$domaine"
SAN_LIST="DNS:$CN"

read -p "Ajouter d'autres SAN (séparés par virgules) ? : " SAN_INPUT
if [[ -n "$SAN_INPUT" ]]; then
    IFS=',' read -ra SAN_ARRAY <<< "$SAN_INPUT"
    for entry in "${SAN_ARRAY[@]}"; do
        entry=$(echo "$entry" | xargs)
        if [[ "$entry" == "$CN" ]]; then
            echo "Le CN $CN est déjà inclus dans le SAN. Ignoré."
        else
            SAN_LIST="$SAN_LIST, DNS:$entry"
        fi
    done
fi

# Récapitulatif
echo ""
echo "RÉCAPITULATIF"
echo "----------------------------"
echo "CN         : $CN"
echo "SAN        : $SAN_LIST"
echo "Organisation : $O"
echo "Unité (OU)   : $OU"
echo "Localité     : $L, $ST, $C"
[ -n "$EMAIL" ] && echo "Email        : $EMAIL"
echo "Durée        : $DAYS jours"
echo "Dossier      : $DEST_BASE/$domaine"
echo ""

read -p "Confirmer la génération ? (o/n) : " confirm
[[ "$confirm" != "o" && "$confirm" != "O" ]] && { echo "Annulé."; exit 1; }

# Chemins
dossier="$DEST_BASE/$domaine"
mkdir -p "$dossier"
key="$dossier/privkey.key"
csr="$dossier/request.csr"
crt="$dossier/cert.crt"
extfile="$dossier/extfile.cnf"

# Génération clé privée ECC
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
    echo "Certificat FQDN signé → $crt"
else
    echo "Erreur : le certificat n’a pas été généré."
fi