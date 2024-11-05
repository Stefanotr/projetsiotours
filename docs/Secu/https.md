# Activer HTTPS avec une Autorité de Certification Personnalisée sur tours.sportludique.fr

Ce guide explique comment générer et installer un certificat SSL auto-signé pour le domaine `tours.sportludique.fr`.

## 🌐 Étape 1 : Créer votre propre Autorité de Certification (CA)

1. **Créer un dossier pour l’AC :**

   ```bash
   mkdir -p ~/myCA
   cd ~/myCA
   ```

2. **Générer la clé privée de l'AC :**

   ```bash
   openssl genrsa -out myCA.key 2048
   ```

3. **Créer un certificat pour l'AC :**

   ```bash
   openssl req -x509 -new -nodes -key myCA.key -sha256 -days 3650 -out myCA.pem
   ```

   Lors de cette étape, répondez aux questions demandées par OpenSSL. Pour le champ **Common Name (CN)**, utilisez `"tours.sportludique.fr CA"` pour identifier l'AC.

---

## 🔐 Étape 2 : Créer le certificat SSL pour `tours.sportludique.fr`

1. **Générer la clé privée pour le site :**

   ```bash
   openssl genrsa -out tours.sportludique.fr.key 2048
   ```

2. **Créer un fichier de configuration OpenSSL pour le certificat SSL :** Créez un fichier nommé `tours.sportludique.fr.conf` avec le contenu suivant :

   ```conf
   [req]
   default_bits = 2048
   prompt = no
   default_md = sha256
   distinguished_name = dn
   req_extensions = req_ext

   [dn]
   CN = tours.sportludique.fr

   [req_ext]
   subjectAltName = @alt_names

   [alt_names]
   DNS.1 = tours.sportludique.fr
   ```

3. **Générer une CSR (Certificate Signing Request) :**

   ```bash
   openssl req -new -key tours.sportludique.fr.key -out tours.sportludique.fr.csr -config tours.sportludique.fr.conf
   ```

4. **Signer le certificat avec votre CA :**

   ```bash
   openssl x509 -req -in tours.sportludique.fr.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out tours.sportludique.fr.crt -days 365 -sha256 -extfile tours.sportludique.fr.conf -extensions req_ext
   ```

---

## 🖥️ Étape 3 : Configurer Apache pour utiliser HTTPS

1. **Déplacer les fichiers vers un dossier accessible pour Apache :**

   ```bash
   sudo cp tours.sportludique.fr.crt /etc/ssl/certs/
   sudo cp tours.sportludique.fr.key /etc/ssl/private/
   ```

2. **Configurer le VirtualHost pour HTTPS :** Ouvrez (ou créez) le fichier de configuration d’Apache pour `tours.sportludique.fr` dans `/etc/apache2/sites-available/` et ajoutez les lignes suivantes :

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

## 🌐 Étape 4 : Importer le certificat CA dans votre navigateur

Pour que votre navigateur reconnaisse le certificat auto-signé sans avertissement de sécurité, ajoutez `myCA.pem` à vos certificats de confiance dans les paramètres de votre navigateur.

---

<style>
code {
  background-color: #f4f4f4;
  color: #333;
  padding: 5px;
  border-radius: 5px;
}
pre {
  background-color: #272822;
  color: #f8f8f2;
  padding: 15px;
  border-radius: 10px;
}
h1 {
  color: #2c3e50;
  border-bottom: 2px solid #007BFF;
  padding-bottom: 0.3em;
}
h2 {
  color: #007BFF;
}
h3 {
  color: #1ABC9C;
}
</style>