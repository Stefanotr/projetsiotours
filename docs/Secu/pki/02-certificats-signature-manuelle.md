# Signature manuelle de certificats (FQDN & Wildcard)

Dans cette étape, nous verrons comment générer un certificat TLS pour un site web ou service interne. Cette procédure est destinée aux cas où un certificat spécifique est nécessaire (nom de domaine unique ou wildcard).

## 📌 Recommandations

- Ne jamais manipuler directement les fichiers dans `/etc/ssl/STS-Root-R2` (répertoire de la CA).
- Les certificats utilisateurs (clé privée, CSR, certificat signé) doivent être générés dans le dossier personnel, par exemple `/home/toursadmin/STS-Root-R2/Client/`.
- Le CN (Common Name) seul ne suffit plus. Depuis la [RFC 2818](https://datatracker.ietf.org/doc/html/rfc2818), le champ `subjectAltName` est **obligatoire**.

## 🔧 Exemple de génération pour un certificat FQDN

```bash
mkdir -p ~/STS-Root-R2/Client/monserveur.mana.lan
cd ~/STS-Root-R2/Client/monserveur.mana.lan

# Clé ECC en prime256v1 (standard recommandé)
openssl ecparam -name prime256v1 -genkey -noout -out privkey.key

# Génération d'une CSR (remplir CN, OU, O, etc.)
openssl req -new -key privkey.key -out request.csr \
  -subj "/C=FR/ST=Centre-Val-de-Loire/L=Tours/O=SportLudique/OU=IT-Departement/CN=monserveur.mana.lan"

# Fichier d'extensions avec subjectAltName obligatoire
cat > extfile.cnf <<EOF
subjectAltName = DNS:monserveur.mana.lan
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF
````

## 🖊️ Signature du certificat par la CA

```bash
sudo openssl ca -in request.csr -out cert.crt \
  -config /etc/ssl/STS-Root-R2/openssl.cnf \
  -extensions v3_usr \
  -extfile extfile.cnf
```

⚠️ Le fichier `index.txt` dans la CA enregistre automatiquement le certificat signé et son numéro de série.

---

## 🌐 Exemple pour un certificat Wildcard

```bash
# CN = *.domaine.lan
openssl req -new -key privkey.key -out request.csr \
  -subj "/C=FR/ST=Centre-Val-de-Loire/L=Tours/O=SportLudique/OU=IT-Departement/CN=*.domaine.lan"

cat > extfile.cnf <<EOF
subjectAltName = DNS:*.domaine.lan, DNS:domaine.lan
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF
```

## 📁 Organisation recommandée

```
~/STS-Root-R2/Client/
├── monserveur.mana.lan/
│   ├── privkey.key
│   ├── request.csr
│   ├── cert.crt
│   └── extfile.cnf
└── wildcard.domaine.lan/
    └── ...
```

---

✅ La CRL et OCSP **ne sont pas encore intégrés à cette étape**, ils seront abordés dans les parties suivantes.