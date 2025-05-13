# Guide de configuration – HSRP sur **TRS‑GW‑01‑FIBRE** et **TRS‑GW‑02‑ADSL**

## 1. Contexte : redondance de passerelle

Le protocole **HSRP** (Hot Standby Router Protocol) permet de présenter une passerelle IP virtuelle unique aux hôtes d’un même segment réseau. Lorsqu’il est mis en œuvre sur les routeurs **TRS‑GW‑01‑FIBRE** et **TRS‑GW‑02‑ADSL**, il garantit :

- **Continuité de service** : en cas de défaillance du routeur actif, le routeur de secours prend immédiatement le relais ;
- **Simplicité de configuration côté client** : une seule passerelle par défaut (IP virtuelle) à diffuser sur le VLAN 224 ;
- **Basculement contrôlé** : prise en compte des priorités et du mécanisme *preempt* pour le retour automatique du routeur principal.

---

## 2. Procédure de configuration

### 2.1 Routeur principal – **TRS‑GW‑01‑FIBRE**

```bash
conf t
interface GigabitEthernet0/0.224
 standby 1 ip 192.168.224.1      ! Adresse IP virtuelle
 standby 1 priority 120          ! Priorité la plus élevée
 standby 1 preempt               ! Reprend le rôle actif après rétablissement
exit
```

### 2.2 Routeur de secours – **TRS‑GW‑02‑ADSL**

```bash
conf t
interface GigabitEthernet0/0.224
 standby 1 ip 192.168.224.1      ! Adresse IP virtuelle partagée
 standby 1 priority 115          ! Priorité inférieure → standby
 standby 1 preempt               ! Peut redevenir actif si l’autre chute
exit
```

> **Remarque** : vérifiez que les adresses IP physiques des deux routeurs sur le sous‑interface *GigabitEthernet0/0.224* restent uniques (ex. : 192.168.224.2 et .3) et que le délai *HSRP hello/hold* par défaut (3/10 s) couvre vos exigences de convergence. Adaptez‑le avec `standby 1 timers msec 1000 3000` si nécessaire.

### 2.3 Validation

```bash
show standby brief        ! Résumé de l’état HSRP
show standby              ! Détails : priorité, rôle, minuteurs
```

Sortie attendue :

- **TRS‑GW‑01‑FIBRE** : `State = Active`, `Priority = 120`, `Virtual IP = 192.168.224.1` ;
- **TRS‑GW‑02‑ADSL** : `State = Standby`, `Priority = 115`, même IP virtuelle.

---

## 3. Conclusion

Cette mise en œuvre d’HSRP offre à Sportludique une passerelle virtuelle résiliente sur le VLAN 224 :

- **Actif** : **TRS‑GW‑01‑FIBRE** (priority 120) ;
- **Secours** : **TRS‑GW‑02‑ADSL** (priority 115).

En cas de panne du routeur principal, la bascule est automatique et transparente ; lors de son retour, le mécanisme *preempt* restitue la hiérarchie initiale sans intervention manuelle.
