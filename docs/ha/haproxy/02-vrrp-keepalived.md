# Configuration de la haute disponibilité avec Keepalived (VRRP)

📄 Fichier : `02-vrrp-keepalived.md`
📁 Emplacement : `docs/ha/haproxy/`

---

## 1. Objectif

Assurer une **haute disponibilité active/passive** entre deux serveurs HAProxy (`TRS-SRV-RP01` et `TRS-SRV-RP02`) grâce au protocole **VRRP**, via Keepalived.

Le système utilise une **IP virtuelle partagée** (`192.168.37.150`) qui bascule automatiquement vers le serveur restant en cas de défaillance.

---

## 2. Informations système

| Élément        | Valeur           |
| -------------- | ---------------- |
| Interface VRRP | `ens3`           |
| IP Master      | `192.168.37.151` |
| IP Backup      | `192.168.37.152` |
| IP virtuelle   | `192.168.37.150` |
| VRID           | `51`             |
| Auth type      | `PASS`           |
| Mot de passe   | `kaboom`         |
---

Souhaite-tu que je génère aussi un petit script Bash pour surveiller l'état de l'IP flottante ou pour tester automatiquement la bascule ?


---

## 3. Installation de Keepalived

Sur **chaque serveur** (RP01 et RP02) :

```bash
sudo apt update
sudo apt install keepalived -y
```

---

## 4. Fichier de configuration – `keepalived.conf`

### Sur `TRS-SRV-RP01` (MASTER)

```conf
vrrp_instance VI_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass kaboom
    }
    virtual_ipaddress {
        192.168.37.150
    }
    track_interface {
        ens3
    }
}
```

### Sur `TRS-SRV-RP02` (BACKUP)

Même configuration, à l’exception de :

```conf
state BACKUP
priority 90
```

---

## 5. Démarrage et test

### Commandes de gestion

```bash
sudo systemctl enable keepalived
sudo systemctl start keepalived
sudo systemctl status keepalived
```

### Vérification de l'IP virtuelle

Sur le MASTER (`TRS-SRV-RP01`) :

```bash
ip a show ens3 | grep 192.168.37.150
```

L'IP virtuelle doit apparaître.

---

## 6. Test de bascule (failover)

1. Arrêter le service Keepalived sur `RP01` :

   ```bash
   sudo systemctl stop keepalived
   ```

2. Sur `RP02`, l'IP `192.168.37.150` doit apparaître automatiquement dans `ip a`.

3. Redémarrer Keepalived sur `RP01` pour le retour à la normale :

   ```bash
   sudo systemctl start keepalived
   ```

---

## 7. Conclusion

Grâce à Keepalived, la configuration assure :

* Une IP flottante assurant l’entrée unique pour les utilisateurs ;
* Une reprise immédiate en cas de défaillance d’un noeud HAProxy ;
* Une supervision simple et efficace, indépendante des applications.

➡️ Étape suivante : [03 – Finalisation de la configuration avec Trustus et HTTPS](03-haproxy-finalisation.md)