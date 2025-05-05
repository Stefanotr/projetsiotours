# Guide de configuration – Switch de distribution **SW‑DISTRIB‑TOURS**

## 1. Contexte : rôle de distribution et segmentation réseau

Le switch **SW‑DISTRIB‑TOURS** constitue le cœur de distribution du site de Tours ; il agrège les liaisons d’accès, concentre les VLAN et relaie le trafic vers la passerelle Internet. Ses objectifs sont :

- **Segmentation** : isoler les flux par usage (management, DMZ, production, conception, etc.) ;
- **Haute disponibilité** : proposer des liaisons trunk redondantes vers le cœur et éviter les boucles via Spanning Tree ;
- **Sécurité d’administration** : limiter la gestion de l’équipement au VLAN de management et aux sessions SSH chiffrées.

---

## 2. Procédure de configuration

### 2.1 Configuration de base

```bash
conf t
hostname SW-DISTRIB-TOURS
!
! Mot de passe privilégié
enable secret <Secret_Privileged_Mode>
!
! Compte d’administration
username admin privilege 15 secret <Secret_Admin>
!
! Bannière légale
banner motd ^
***************************************************************************
*      Accès réservé : toute activité est enregistrée et auditée.         *
*      Support IT : support@sportludiques.com                              *
***************************************************************************
^
exit
```

### 2.2 VLAN de management et SVI

```bash
vlan 220
 name Management
!
interface Vlan220
 ip address 10.10.10.20 255.255.255.0
 no shutdown
```

### 2.3 Définition des VLANs de service

```bash
vlan 221
 name Services
vlan 222
 name DMZ
vlan 223
 name A_Definir
vlan 224
 name Interconnexion
vlan 225
 name Production
vlan 226
 name Conception
```

### 2.4 Sécurisation de l’accès distant (SSH)

```bash
ip domain-name sportludique.fr
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
exit
```

### 2.5 Configuration des ports

```bash
! Uplink trunk vers le cœur
interface GigabitEthernet0/24
 description Uplink_Core
 switchport mode trunk
 spanning-tree portfast disable
 no shutdown
!
! Ports d’accès utilisateurs
interface GigabitEthernet0/1
 description Poste_Admin1
 switchport mode access
 switchport access vlan 220
 spanning-tree portfast
 no shutdown
!
interface GigabitEthernet0/2
 description Poste_Admin2
 switchport mode access
 switchport access vlan 220
 spanning-tree portfast
 no shutdown
!
interface GigabitEthernet0/3
 description Serveur_DMZ
 switchport mode access
 switchport access vlan 222
 spanning-tree portfast
 no shutdown
!
interface GigabitEthernet0/4
 description Banc_Conception
 switchport mode access
 switchport access vlan 226
 spanning-tree portfast
 no shutdown
```

---

## 3. Conclusion

Cette configuration confère à **SW‑DISTRIB‑TOURS** :

- Une **administration sécurisée** au travers du VLAN 220 et de SSH v2 ;
- Une **segmentation claire** grâce à des VLAN dédiés aux différents usages ;
- Une **intégration transparente** avec le cœur du réseau par le trunk principal, prêt à être doublé pour la redondance si nécessaire.

Le switch est ainsi aligné sur les standards Sportludique et peut évoluer vers des fonctionnalités avancées (QoS, 802.1X, agrégation de liens, supervision SNMP) sans modifier la configuration actuelle.
