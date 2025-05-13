# Activer HTTPS avec une Autorité de Certification personnalisée sur `tours.sportludique.fr`

Ce guide explique comment générer un certificat SSL signé par une autorité interne, l’installer et le configurer pour le site `tours.sportludique.fr`.

Ce certificat est utilisé dans le cadre du **site web vitrine de SportLudique**, hébergé localement et exposé publiquement via un **reverse proxy HAProxy**, dont la configuration est abordée dans la section [Haute-disponibilité](../ha/haproxy/intro.md).

---

## Étape 1 – Récupération du certificat d’autorité

Avant toute configuration, il est nécessaire que le client (navigateur) **fasse confiance à l’autorité interne STS Root R2**.

Téléchargez le certificat racine depuis :
[https://trustus.mana.lan/ca.crt](https://trustus.mana.lan/ca.crt)

Puis, installez ce fichier dans le magasin de certificats de confiance de votre navigateur ou de votre OS.

---

## Étape 2 – Génération du certificat SSL pour `tours.sportludique.fr`

1. **Créer une clé privée pour le site :**

   ```bash
   openssl genrsa -out tours.sportludique.fr.key 2048
   ```

2. **Créer un fichier de configuration OpenSSL (ex : `tours.sportludique.fr.conf`)** :

   ```ini
   [req]
   default_bits       = 2048
   prompt             = no
   default_md         = sha256
   distinguished_name = dn
   req_extensions     = req_ext

   [dn]
   CN = tours.sportludique.fr

   [req_ext]
   subjectAltName = @alt_names

   [alt_names]
   DNS.1 = tours.sportludique.fr
   ```

3. **Générer la CSR :**

   ```bash
   openssl req -new -key tours.sportludique.fr.key \
     -out tours.sportludique.fr.csr \
     -config tours.sportludique.fr.conf
   ```

4. **Signer la CSR avec la CA STS Root R2 :**

   (Depuis la machine qui héberge la CA)

   ```bash
   openssl x509 -req \
     -in tours.sportludique.fr.csr \
     -CA /etc/ssl/STS-Root-R2/certs/ca.crt \
     -CAkey /etc/ssl/STS-Root-R2/private/ca.key \
     -CAcreateserial \
     -out tours.sportludique.fr.crt \
     -days 365 \
     -sha256 \
     -extfile tours.sportludique.fr.conf \
     -extensions req_ext
   ```

---

## Étape 3 – Déploiement avec Apache (en local)

1. **Déplacer les fichiers dans les emplacements standards :**

   ```bash
   sudo cp tours.sportludique.fr.crt /etc/ssl/certs/
   sudo cp tours.sportludique.fr.key /etc/ssl/private/
   ```

2. **Créer un fichier Apache dans `/etc/apache2/sites-available/tours.sportludique.fr.conf` :**

   ```apache
   <VirtualHost *:443>
       ServerName tours.sportludique.fr
       DocumentRoot /var/www/html/sportludique_parodie

       SSLEngine on
       SSLCertificateFile /etc/ssl/certs/tours.sportludique.fr.crt
       SSLCertificateKeyFile /etc/ssl/private/tours.sportludique.fr.key

       <Directory /var/www/html/sportludique_parodie>
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```

3. **Activer le module SSL et le site :**

   ```bash
   sudo a2enmod ssl
   sudo a2ensite tours.sportludique.fr
   sudo systemctl restart apache2
   ```

---

## Étape 4 – Intégration avec le reverse proxy HAProxy

Dans l’environnement final, **le site `tours.sportludique.fr` est servi via HAProxy**, qui se charge de la terminaison TLS et de la redirection vers l’Apache local.

La configuration de HAProxy est décrite dans la page suivante :
➡️ [Voir la configuration HAProxy](../ha/haproxy/intro.md)

Le certificat `.crt` peut être concaténé avec sa clé `.key` pour HAProxy si besoin :

```bash
cat /etc/ssl/certs/tours.sportludique.fr.crt /etc/ssl/private/tours.sportludique.fr.key > /etc/ssl/haproxy/tours.bundle.pem
```

---

## Étape 5 – Import manuel du certificat pour tests

Pour tester l'accès HTTPS depuis un navigateur **en interne** sans erreur de sécurité :

1. Ouvrir `https://tours.sportludique.fr` depuis le réseau local.
2. Si votre navigateur affiche une alerte, installer manuellement le certificat `ca.crt` depuis `https://trustus.mana.lan/`.