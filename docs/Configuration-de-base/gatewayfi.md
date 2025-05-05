# Configuration avancée du routeur **TRS‑GW‑01‑FIBRE**

## 1. Contexte : lien fibre dédié et exigences de fiabilité

Sportludique déploie un accès fibre optique symétrique pour couvrir les besoins suivants :

- **Capacité élevée** : distribution de contenus multimédias en direct et synchronisation volumineuse de données entre sites ;
- **Faible latence** : sessions de jeu en ligne, webinaires interactifs et solutions de bureautique cloud ;
- **Qualité de service** : séparation des flux critiques (paiement, VPN, supervision) du trafic moins prioritaire ;
- **Sécurité renforcée** : administration distante via SSH et traçabilité des modifications.

Le routeur TRS‑GW‑01‑FIBRE assure la passerelle principale entre le réseau interne et Internet via une **liaison fibre dédiée**. La continuité de service peut être complétée par un lien de secours (ADSL ou 4G) non décrit ici.

---

## 2. Procédure de configuration

### 2.1 Configuration de base

```bash
conf t
hostname TRS-GW-01-FIBRE
!
! Sécurisation du mode privilégié
enable secret <Secret_Privileged_Mode>
!
! Compte d’administration SSH
username admin privilege 15 secret <Secret_Admin>
!
! Bannière légale
banner motd ^
***************************************************************************
*          Accès réservé : toute activité est enregistrée et auditée.      *
*     Support IT : support@sportludique.com                                 *
***************************************************************************
^
exit
```

### 2.2 Configuration des interfaces

```bash
! VLAN Management (VLAN 220)
interface GigabitEthernet0/0.220
 encapsulation dot1Q 220
 ip address 10.10.10.1 255.255.255.0
 no shutdown
exit

! VLAN Interconnexion (VLAN 224)
interface GigabitEthernet0/0.224
 encapsulation dot1Q 224
 ip address 192.168.224.2 255.255.255.0
 ip nat inside
 ip virtual-reassembly in
 no shutdown
exit

! Interface WAN fibre (accès dédié)
interface GigabitEthernet0/1
 ip address 183.44.37.1 255.255.255.252
 ip nat outside
 ip virtual-reassembly in
 no shutdown
exit
```

> **Note :** si une seconde fibre ou un lien de secours est prévu, répliquer la section WAN sur l’interface concernée et mettre en place un suivi (track) pour la route par défaut.

### 2.3 Sécurisation SSH

```bash
ip domain-name sportludique.fr
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
exit
```

### 2.4 NAT et contrôle d’accès

```bash
! Réseaux internes autorisés à sortir
access-list 1 permit 172.28.128.0 0.0.31.255
access-list 1 permit 192.168.0.0   0.0.255.255
!
! NAT surcharge (PAT) vers la fibre
ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

### 2.5 Routage statique

```bash
! Route par défaut vers le FAI fibre
ip route 0.0.0.0 0.0.0.0 183.44.37.2
!
! Routage interne
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0   255.255.0.0   192.168.224.254
```

### 2.6 Validation et tests

```bash
! État des interfaces
show ip interface brief

! Test de connectivité externe
ping 8.8.8.8 repeat 5

! Traductions NAT actives
show ip nat translations
```

---

## 3. Conclusion

Cette configuration place le routeur **TRS‑GW‑01‑FIBRE** au cœur du réseau Sportludique avec :

- **Sécurité** : authentification locale forte, chiffrement SSH et bannière légale ;
- **Performance** : liaison fibre à haut débit, VLAN dédié au management et NAT optimisé ;
- **Simplicité opérationnelle** : commandes de vérification rapides pour le support NOC.

Elle fournit une base fiable et évolutive pour les futurs services (QoS avancée, IPSec, redondance multi‑WAN) tout en répondant aux exigences actuelles de l’entreprise.
