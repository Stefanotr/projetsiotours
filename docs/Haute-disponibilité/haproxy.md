# 🌐 Installation et Configuration d'HAProxy sur Debian 🚀

## 📘 **Introduction**

HAProxy (High Availability Proxy) est une solution performante et flexible pour l'équilibrage de charge et le proxying HTTP/HTTPS. Ce guide vous accompagne dans l'installation et la configuration d'HAProxy sur un système Debian, avec une configuration personnalisée pour gérer les connexions sécurisées (SSL) et équilibrer les charges entre plusieurs serveurs backend.

---

## 📋 **Objectif**

Configurer HAProxy pour :
1. Accepter les connexions HTTP et HTTPS en frontend.
2. Équilibrer les requêtes utilisateur en backend via un algorithme round-robin.
3. Assurer la persistance des sessions utilisateurs (sticky sessions).
4. Gérer les certificats SSL pour des connexions sécurisées.

---

## 🛠️ **1. Installation d’HAProxy**

### Étapes d’installation

1. **Mettre à jour le système** :
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Installer HAProxy** :
   ```bash
   sudo apt install haproxy -y
   ```

3. **Vérifiez la version installée** :
   ```bash
   haproxy -v
   ```

---

## 🖋️ **2. Configuration Globale d’HAProxy**

### Chemin du fichier de configuration

Le fichier principal d'HAProxy se trouve ici :
```bash
/etc/haproxy/haproxy.cfg
```

### Configuration Globale

Ajoutez ou remplacez les sections suivantes dans le fichier `haproxy.cfg` :

<pre>
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # SSL settings
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http
</pre>
---

## 🔗 **3. Configuration Frontend et Backend**

### **Frontend (wwwtest)**

Le **frontend** est le point d'entrée des connexions. Il accepte les requêtes HTTP et HTTPS, applique les règles SSL, et redirige les requêtes vers le backend.

```plaintext
frontend wwwtest
    bind *:80
    bind *:443 ssl crt /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
    mode http
    default_backend wwwtest_http_backend
```

- **`bind *:80`** : Accepte les requêtes HTTP sur le port 80.
- **`bind *:443 ssl crt`** : Accepte les requêtes HTTPS sur le port 443 en utilisant le certificat SSL spécifié.
- **`default_backend`** : Redirige les requêtes vers le backend `wwwtest_http_backend`.

### **Backend (wwwtest_http_backend)**

Le **backend** gère l'équilibrage de charge entre les serveurs réels.

```plaintext
backend wwwtest_http_backend
    mode http
    balance roundrobin
    option forwardfor
    stick-table type ip size 100k expire 5m
    stick on src
    server srv-http1 192.168.37.130:80 check
    server srv-http2 192.168.37.140:80 check
```

- **`balance roundrobin`** : Utilise un algorithme round-robin pour distribuer les requêtes.
- **`option forwardfor`** : Ajoute l’en-tête `X-Forwarded-For` pour conserver l’adresse IP du client.
- **`stick-table` et `stick on src`** : Assure que les requêtes d’une même IP sont dirigées vers le même serveur.
- **`server`** : Liste les serveurs backend avec leur adresse IP et port.

---

## 🔐 **4. Gestion des Certificats SSL**

### Emplacement du certificat

Placez votre certificat et votre clé dans le répertoire suivant :
```bash
/etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
```

Assurez-vous que ce fichier contient :
1. Le certificat public.
2. La clé privée.

### Vérifiez les permissions
Protégez vos fichiers de certificat :
```bash
sudo chown root:root /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
sudo chmod 600 /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
```

---

## ✅ **5. Vérification et Redémarrage**

### Vérifiez la syntaxe de la configuration
Avant de redémarrer HAProxy, validez la configuration :
```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

### Redémarrez HAProxy
Une fois validée :
```bash
sudo systemctl restart haproxy
```

### Activez HAProxy au démarrage
```bash
sudo systemctl enable haproxy
```

---

## 📊 **6. Vérification Fonctionnelle**

1. **Vérifiez l’écoute des ports** :
   ```bash
   sudo netstat -tulnp | grep haproxy
   ```

2. **Testez l’accès au frontend** :
   - Accédez à : `http://<IP_du_serveur>`
   - Pour HTTPS : `https://<IP_du_serveur>`

3. **Surveillez les logs** :
   ```bash
   sudo tail -f /var/log/haproxy.log
   ```

---

## 🎯 **7. Maintenance et Suivi**

- **Fichier de logs** :
  Les logs se trouvent dans :
  ```bash
  /var/log/haproxy.log
  ```

- **Mises à jour** :
  Maintenez votre serveur à jour pour bénéficier des dernières fonctionnalités et correctifs :
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

---

## 📚 **Conclusion**

Votre configuration HAProxy est opérationnelle, offrant une solution robuste pour gérer les connexions sécurisées (HTTPS) et équilibrer le trafic utilisateur entre plusieurs serveurs backend. Ce setup garantit haute disponibilité et sécurité pour vos applications. 🎉