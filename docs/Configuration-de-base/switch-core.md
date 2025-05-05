# Guide de configuration – Switch cœur **TRS‑SW‑CORE**

## 1. Contexte : rôle central et exigences de performance

Le switch **TRS‑SW‑CORE** est le nœud principal de l’infrastructure Sportludique. Il agrège le trafic des switches de distribution, assure le routage inter‑VLAN et relaie les flux vers la passerelle Internet. Les objectifs clés demeurent :

- **Débit élevé** : commutation L2/L3 avec forte capacité de traitement.
- **Routage inter‑VLAN** : distribution efficace du trafic entre segments logiques.
- **Haute disponibilité** : liens agrégés (Port‑Channel 1) et trunks multiples.
- **Sécurité d’administration** : gestion isolée via le VLAN 220 et SSH.

---

## 2. Procédure de configuration

### 2.1 Configuration de base

```bash
conf t
hostname TRS-SW-CORE
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
*      Accès réservé : toute activité est enregistrée et auditée.          *
*      Support IT : support@sportludiques.com                               *
***************************************************************************
^
exit
```

### 2.2 VLAN de management et SVI

```bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 ip helper-address 172.28.131.50
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
```

### 2.3 Définition des VLANs

<pre>
vlan 125
 name Infra_Backup
!
vlan 220
 name Management
!
vlan 221
 name Services
!
vlan 222
 name DMZ
!
vlan 223
 name A_Definir
!
vlan 224
 name Interconnexion
!
vlan 225
 name Production
!
vlan 226
 name Conception
!
vlan 227
 name Tests
!
vlan 228
 name OT_Zone
!
vlan 229
 name Transit
</pre>

### 2.4 SVIs supplémentaires

```bash
interface Vlan125
 ip address 192.168.125.1 255.255.255.0
!
interface Vlan221
 ip address 172.28.131.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
!
interface Vlan225
 ip address 172.28.135.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
!
interface Vlan226
 ip address 172.28.136.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
!
interface Vlan227
 ip address 172.28.137.1 255.255.255.0
 ip helper-address 172.28.131.50
 ip access-group ALLOW_SSH_VLAN220 in
!
interface Vlan228
 ip address 172.28.138.10 255.255.255.0
!
interface Vlan229
 ip address 192.168.229.254 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
```

### 2.5 Sécurisation de l’accès distant (SSH)

```bash
ip domain-name sportludique.fr
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
line vty 5 15
 login local
 transport input ssh
exit
```

### 2.6 Routage IP

```bash
ip routing
ip route 0.0.0.0 0.0.0.0 192.168.229.1
```

### 2.7 Listes de contrôle d’accès

```bash
ip access-list extended ALLOW_SSH_VLAN220
 10 permit tcp 10.10.10.0 0.0.0.255 any eq 22
 20 deny   tcp any any eq 22
 30 permit ip any any
```

### 2.8 Agrégation et ports trunk

```bash
! Port‑Channel d’uplink principal
interface Port-channel1
 switchport mode trunk
!
interface GigabitEthernet1/0/18
 description "Uplink LACP"
 switchport mode trunk
 channel-group 1 mode active
!
interface GigabitEthernet1/0/19
 description "Uplink LACP"
 switchport mode trunk
 channel-group 1 mode active
!
! Trunks additionnels
interface GigabitEthernet1/0/20
 switchport mode trunk
!
interface GigabitEthernet1/0/21
 switchport mode trunk
!
interface GigabitEthernet1/0/22
 switchport mode trunk
!
interface GigabitEthernet1/0/23
 switchport mode trunk
!
interface GigabitEthernet1/0/24
 switchport mode trunk
```

### 2.9 Ports d’accès

```bash
interface GigabitEthernet1/0/1
 switchport mode access
 switchport access vlan 220
!
interface GigabitEthernet1/0/2
 switchport mode access
 switchport access vlan 220
!
interface GigabitEthernet1/0/3
 switchport mode access
 switchport access vlan 221
 shutdown
!
interface GigabitEthernet1/0/4
 switchport mode access
 switchport access vlan 221
!
interface GigabitEthernet1/0/5
 switchport mode access
 switchport access vlan 222
!
interface GigabitEthernet1/0/6
 switchport mode access
 switchport access vlan 222
!
interface GigabitEthernet1/0/7
 switchport mode access
 switchport access vlan 223
!
interface GigabitEthernet1/0/8
 switchport mode access
 switchport access vlan 223
!
interface GigabitEthernet1/0/9
 switchport mode access
 switchport access vlan 224
!
interface GigabitEthernet1/0/10
 switchport mode access
 switchport access vlan 224
```

---

## 3. Conclusion

La documentation reflète désormais la configuration effective de **TRS‑SW‑CORE** :

- **Administration sécurisée** via le VLAN 220, ACL ciblée et SSH v2.
- **Segmentation étendue** (VLAN 125, 220‑229) avec SVIs et relais DHCP.
- **Connectivité redondante** grâce au Port‑Channel 1 et à plusieurs trunks.
- **Passerelle par défaut** vers 192.168.229.1, assurant la sortie Internet.

Cette base garantit la performance, la résilience et la conformité aux standards Sportludique, tout en restant prête pour des extensions futures (QoS, 802.1X, monitoring SNMP). 
