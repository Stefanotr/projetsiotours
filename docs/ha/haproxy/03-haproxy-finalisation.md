# Finalisation et amélioration de la configuration HAProxy

## 1. Objectif

Cette étape a pour but de **finaliser l’infrastructure HAProxy** déployée pour le site `tours.sportludique.fr` en :

* Redirigeant proprement le domaine racine vers `www.`
* Intégrant le sous-domaine `trustus.tours.sportludique.fr`
* Corrigeant la gestion des certificats
* Sécurisant le trafic HTTPS
* Préparant le système à l’évolutivité et à la supervision

---

## 2. Points de vigilance

* **Chemin du certificat TLS** : le certificat `.pem` utilisé pour HTTPS est stocké ici :

  ```bash
  /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
  ```

  > Il doit contenir **la clé privée + le certificat** concaténés.

* **Ajout du sous-domaine `trustus.tours.sportludique.fr`** dans le DNS :

  * Entrée A vers `192.168.37.150` (l’IP virtuelle de VRRP)
  * Visible sur le LAN, et potentiellement NATé en externe

---

## 3. Fichier `haproxy.cfg` finalisé

Le fichier de configuration HAProxy final comporte les éléments suivants :

### a) Section `global` et `defaults`

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

    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    ssl-default-bind-ciphers ECDHE-...
    ssl-default-bind-ciphersuites TLS_AES_...
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
    ...
```

---

### b) Frontend HTTP (port 80)

```ini
frontend frontend_http
    bind *:80
    mode http

    acl is_root      hdr(host) -i tours.sportludique.fr
    acl is_www       hdr(host) -i www.tours.sportludique.fr
    acl is_trustus   hdr(host) -i trustus.tours.sportludique.fr

    use_backend backend_www      if is_www
    use_backend backend_trustus  if is_trustus

    redirect location https://www.tours.sportludique.fr code 301 if is_root
    redirect location https://www.tours.sportludique.fr code 301
```

---

### c) Frontend HTTPS (port 443)

```ini
frontend frontend_https
    bind *:443 ssl crt /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
    mode http

    acl is_root      hdr(host) -i tours.sportludique.fr
    acl is_www       hdr(host) -i www.tours.sportludique.fr
    acl is_trustus   hdr(host) -i trustus.tours.sportludique.fr

    use_backend backend_www      if is_www
    use_backend backend_trustus  if is_trustus

    redirect location https://www.tours.sportludique.fr code 301 if is_root
    default_backend backend_www
```

---

### d) Backend principal – `www`

```ini
backend backend_www
    mode http
    balance roundrobin
    option forwardfor
    stick-table type ip size 100k expire 5m
    stick on src
    server web1 192.168.37.110:80 check
    server web2 192.168.37.115:80 check
```

---

### e) Backend secondaire – `trustus`

```ini
backend backend_trustus
    mode http
    option forwardfor
    server trustus 192.168.37.60:80 check port 80
```

---

## 4. Conseils supplémentaires

* Ajoute un **VirtualHost Apache** sur le serveur `trustus` pour servir :

  * Le certificat racine : `https://trustus.tours.sportludique.fr/ca.crt`
  * Une page HTML d’aide à l’installation manuelle
* Pense à configurer un `/stats` pour visualiser l'état des HAProxy :

  ```ini
  listen stats
      bind *:9000
      stats enable
      stats uri /
      stats realm Haproxy\ Statistics
      stats auth admin:kaboom
  ```
* Vérifie les **permissions** du fichier `.pem` :

  ```bash
  sudo chmod 600 /etc/ssl/tours.sportludique.fr/tours.sportludique.fr.pem
  ```

---

## 5. Conclusion

La configuration HAProxy finale permet désormais :

* Une publication HTTPS propre pour plusieurs sous-domaines
* Un routage intelligent basé sur l’URL demandée
* L’ajout d’un service auxiliaire `trustus` pour l’infrastructure PKI
* Une résilience maximale grâce au cluster HAProxy supervisé par VRRP