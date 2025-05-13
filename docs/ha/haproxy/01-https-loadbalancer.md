# Configuration – HAProxy sur Debian

## 1. Contexte : répartition de charge pour `sportludique.fr`

Afin d’améliorer la résilience et la performance de son site vitrine `sportludique.fr`, la DSI a choisi de mettre en place une infrastructure d’équilibrage de charge basée sur **HAProxy**. Ce répartiteur sera chargé de distribuer les requêtes web entrantes entre deux fermes de serveurs :

* Un cluster principal local (on-premise)
* Un cluster de secours activable si nécessaire

Cette mise en place répond aux besoins suivants :

* Répartition **équitable du trafic HTTP/HTTPS** (round-robin)
* Terminaison TLS unique pour simplifier la gestion des certificats
* Persistance de session utilisateur (via IP source)
* Supervision des serveurs backends avec détection automatique de panne
* Évolutivité par ajout ou retrait de serveurs sans coupure

---

## 2. Installation et configuration de HAProxy

### 2.1 Installation sur Debian

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install haproxy -y
haproxy -v  # Vérification de la version
```

---

### 2.2 Fichier `/etc/haproxy/haproxy.cfg`

#### a) Section `global` et `defaults`

```ini
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    ca-base  /etc/ssl/certs
    crt-base /etc/ssl/private

    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:...
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
```

---

#### b) Frontend HTTPS

```ini
frontend wwwtest
    bind *:80
    bind *:443 ssl crt /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
    mode http
    default_backend wwwtest_http_backend
```

---

#### c) Backend avec équilibre de charge

```ini
backend wwwtest_http_backend
    mode http
    balance roundrobin
    option forwardfor
    stick-table type ip size 100k expire 5m
    stick on src
    server srv-http1 192.168.37.110:80 check
    server srv-http2 192.168.37.115:80 check
```

---

### 2.3 Certificats TLS

Concaténez le certificat et la clé privée dans un fichier `.pem` :

```bash
sudo mkdir -p /etc/ssl/tours.sportludique.fr
cat cert.crt privkey.key > /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
sudo chown root:root /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
sudo chmod 600 /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
```

---

### 2.4 Lancement et activation

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg  # Vérification
sudo systemctl restart haproxy
sudo systemctl enable haproxy
```

---

### 2.5 Vérifications

```bash
sudo ss -tulpn | grep haproxy         # Vérifier que les ports 80 et 443 sont ouverts
sudo tail -f /var/log/haproxy.log     # Suivi des requêtes et erreurs
```

---

## 3. Résultat attendu

Le service `sportludique.fr` est désormais :

* Accessible en HTTP et HTTPS depuis LAN et Internet
* Sécurisé avec un certificat signé par l’AC STS Root R2
* Réparti entre plusieurs serveurs web de manière transparente
* Résilient en cas de panne d’un backend
* Capable de maintenir les sessions actives par IP

➡️ Étape suivante : [02 – Mise en place de VRRP avec Keepalived](02-vrrp-keepalived.md)