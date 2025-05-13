# Création de l'autorité de certification STS Root R2

## Objectif

Mettre en place une autorité de certification (CA) locale nommée **STS Root R2** dans le but de signer les certificats des serveurs internes de SportLudique. Cette CA repose sur une **clé elliptique `prime256v1`**, auto-signée, avec une structure de fichiers compatible avec OpenSSL.

---

## 1. Arborescence de la CA

L’infrastructure de la CA est stockée dans le dossier :  
`/etc/ssl/STS-Root-R2`

Structure minimale à créer :

```bash
/etc/ssl/STS-Root-R2/
├── certs/           # Contient le certificat public de la CA (ca.crt)
├── private/         # Contient la clé privée de la CA (ca.key)
├── crl/             # Liste des certificats révoqués (à venir)
├── newcerts/        # Stocke tous les certificats signés
├── index.txt        # Base de données des certificats
├── serial           # Compteur pour numéro de série
├── openssl.cnf      # Configuration OpenSSL spécifique
````

Initialisation des fichiers nécessaires :

```bash
sudo mkdir -p /etc/ssl/STS-Root-R2/{certs,crl,newcerts,private}
sudo touch /etc/ssl/STS-Root-R2/index.txt
echo 1000 | sudo tee /etc/ssl/STS-Root-R2/serial
```

---

## 2. Génération de la clé privée de la CA

La clé privée est une clé elliptique basée sur la courbe `prime256v1` :

```bash
openssl ecparam -name prime256v1 -genkey -noout -out /etc/ssl/STS-Root-R2/private/ca.key
chmod 600 /etc/ssl/STS-Root-R2/private/ca.key
```

---

## 3. Signature du certificat auto-signé

Création d’un certificat valide pour 10 ans (3650 jours) :

```bash
openssl req -x509 -new -nodes \
  -key /etc/ssl/STS-Root-R2/private/ca.key \
  -sha256 -days 3650 \
  -subj "/C=FR/ST=Centre-Val-de-Loire/L=Tours/O=SportLudique Trust Services/OU=IT-Departement/CN=STS Root R2" \
  -out /etc/ssl/STS-Root-R2/certs/ca.crt
```

---

## 4. Configuration d’OpenSSL (openssl.cnf)

Voici un exemple de configuration simplifiée, sans CRL ni OCSP (pour cette première étape) :

```ini
[ ca ]
default_ca = CA_default

[ CA_default ]
dir             = /etc/ssl/STS-Root-R2
certs           = $dir/certs
crl_dir         = $dir/crl
database        = $dir/index.txt
new_certs_dir   = $dir/newcerts
certificate     = $dir/certs/ca.crt
serial          = $dir/serial
private_key     = $dir/private/ca.key
default_md      = sha256
default_days    = 825
policy          = policy_match
x509_extensions = v3_ca
copy_extensions = copy

[ policy_match ]
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
```

---

## 5. Résultat

Le certificat de l’autorité STS Root R2 est maintenant opérationnel :

* **Clé privée** : `/etc/ssl/STS-Root-R2/private/ca.key`
* **Certificat public** : `/etc/ssl/STS-Root-R2/certs/ca.crt`
* Peut désormais signer des certificats serveurs (FQDN, Wildcard ou Intermédiaires)

---

## Étapes suivantes

* Publication du certificat racine (installation sur les postes clients)
* Configuration OCSP et CRL
* Génération de certificats serveur via scripts automatisés

---

> Ce certificat racine auto-signé doit être **importé manuellement** dans les navigateurs et systèmes clients de l’entreprise pour être reconnu comme de confiance.