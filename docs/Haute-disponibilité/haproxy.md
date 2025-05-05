# Guide de configuration – HAProxy sur Debian

## 1. Contexte : répartiteur de charge pour **sportludique.fr**

Le site **sportludique.fr** subit des pics de trafic lors des ouvertures d’inscription et des opérations marketing. Deux fermes web (cluster principal on‑premise et cluster de secours) doivent partager la charge tout en assurant la continuité de service.

Un répartiteur **Layer 7** est requis pour :

- **Distribuer** les requêtes HTTP/HTTPS entre les clusters à l’aide d’un algorithme *round‑robin* ;
- **Terminer le TLS** en un point unique, simplifiant la gestion des certificats ;
- **Préserver les sessions** (sticky sessions) grâce à l’adresse IP source ;
- **Surveiller** la santé des nœuds et retirer automatiquement tout backend défaillant ;
- **Évoluer** facilement en ajoutant ou retirant des serveurs.

HAProxy répond à ces exigences tout en offrant performance et fiabilité.

---

## 2. Procédure de configuration

### 2.1 Installation du paquet

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install haproxy -y
haproxy -v   # Vérifier la version
```

### 2.2 Fichier `/etc/haproxy/haproxy.cfg`

#### 2.2.1 Sections **global** et **defaults**

<pre>
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Emplacements SSL
        ca-base  /etc/ssl/certs
        crt-base /etc/ssl/private

        # Ciphers TLS intermédiaire (Mozilla)
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
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

#### 2.2.2 Frontend **wwwtest**

```bash
frontend wwwtest
    bind *:80
    bind *:443 ssl crt /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
    mode http
    default_backend wwwtest_http_backend
```

#### 2.2.3 Backend **wwwtest_http_backend**

```bash
backend wwwtest_http_backend
    mode http
    balance roundrobin
    option forwardfor
    stick-table type ip size 100k expire 5m
    stick on src
    server srv-http1 192.168.37.110:80 check
    server srv-http2 192.168.37.115:80 check
```

### 2.3 Gestion des certificats

```bash
sudo mkdir -p /etc/ssl/tours.sportludique.fr
# Copiez certificat + clé concaténés :
#   /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
sudo chown root:root /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
sudo chmod 600  /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
```

### 2.4 Validation et démarrage

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg   # Valider la syntaxe
sudo systemctl restart haproxy
sudo systemctl enable haproxy                 # Activer au démarrage
```

### 2.5 Vérifications

```bash
sudo ss -tulpn | grep haproxy         # Ports écoutés
sudo tail -f /var/log/haproxy.log     # Suivi des logs
```

---

## 3. Conclusion

HAProxy assure désormais :

- **Frontaux HTTP/HTTPS** sécurisés (TLS ≥ 1.2) ;
- **Équilibrage round‑robin** vers les serveurs `192.168.37.110` et `192.168.37.115` ;
- **Persistance de session** via l’IP source ;
- **Scalabilité** et **résilience** adaptées aux montées en charge du site Sportludique.
