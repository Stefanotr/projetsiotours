```markdown
# Documentation de Configuration du Switch SW-Core-Tours

## Informations Générales
- **Nom d'hôte** : `SW-Core-Tours`
- **Version d'IOS** : 17.6
- **Domaine IP** : `sportludique.fr`
- **Licence activée** : `network-essentials` avec l'add-on `dna-essentials`
- **Mode de Redondance** : `SSO` (Stateful Switchover)

---

## 1. Gestion VRF (Virtual Routing and Forwarding)
### VRF Management
```bash
vrf definition Mgmt-vrf
 address-family ipv4
 address-family ipv6
```
- **Description** : La VRF `Mgmt-vrf` est définie pour gérer les flux IPv4 et IPv6 séparément du trafic réseau général.

---

## 2. Sécurité

### Secret d'activation
```bash
enable secret 9 $9$xiT2VJ5L0eIBAk$IJC8mDKsIj3Xp7pNt4D7Uq5Hhe9LxvGtQyVKuFKAHq6
```
- **Description** : Le mot de passe d'activation (enable secret) est configuré avec un algorithme de chiffrement fort.

### Utilisateur local
```bash
username admin secret 9 $9$7e7Kh.VTlh5nlk$.Q3oi3ImEnpAsXab.6XOQECtCLFAoYtwYgpoiV6DoIc
```
- **Description** : L'utilisateur local `admin` est défini avec un mot de passe chiffré.

### ACL SSH (VLAN220)
```bash
ip access-list extended ALLOW_SSH_VLAN220
 10 permit tcp 10.10.10.0 0.0.0.255 any eq 22
 20 deny   tcp any any eq 22
 30 permit ip any any
```
- **Description** : Cette liste de contrôle d'accès (ACL) permet uniquement le trafic SSH (port 22) provenant du sous-réseau `10.10.10.0/24`. Tout autre trafic SSH est refusé.

---

## 3. Interfaces VLAN
### VLAN 220
```bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
```
- **Description** : L'interface `Vlan220` a l'adresse IP `10.10.10.10/24` et applique l'ACL `ALLOW_SSH_VLAN220`.

### VLAN 221
```bash
interface Vlan221
 ip address 172.28.131.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
```
- **Description** : L'interface `Vlan221` a l'adresse IP `172.28.131.1/24` et applique également l'ACL `ALLOW_SSH_VLAN220`.

### VLAN 222 & 223 avec helper DHCP
```bash
interface Vlan222
 ip address 172.28.132.1 255.255.255.0
 ip helper-address 172.28.131.15
 ip access-group ALLOW_SSH_VLAN220 in
```
```bash
interface Vlan223
 ip address 172.28.133.1 255.255.255.0
 ip helper-address 172.28.131.15
 ip access-group ALLOW_SSH_VLAN220 in
```
- **Description** : Les VLANs `222` et `223` ont des adresses IP respectives et utilisent un relais DHCP (`helper-address`) vers `172.28.131.15`.

### VLAN 229
```bash
interface Vlan229
 ip address 10.0.0.10 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
```
- **Description** : Le VLAN `229` utilise l'adresse IP `10.0.0.10/24` avec l'ACL pour SSH.

---

## 4. Routage IP
### Routage activé et route par défaut
```bash
ip routing
ip route 0.0.0.0 0.0.0.0 10.0.0.1
```
- **Description** : Le routage est activé sur le switch avec une route par défaut vers `10.0.0.1`.

---

## 5. Services HTTP et HTTPS
### Serveur HTTP sécurisé
```bash
ip http server
ip http authentication local
ip http secure-server
```
- **Description** : Les serveurs HTTP et HTTPS sont activés avec une authentification locale.

---

## 6. Accès SSH
### Configuration SSH
```bash
line vty 0 4
 login local
 transport input ssh
```
```bash
line vty 5 15
 login local
 transport input ssh
```
- **Description** : L'accès SSH est activé et uniquement les utilisateurs locaux peuvent se connecter via SSH.

---

## 7. Configuration Spanning Tree
```bash
spanning-tree mode rapid-pvst
spanning-tree extend system-id
```
- **Description** : Le protocole Spanning Tree fonctionne en mode `Rapid-PVST` (Per-VLAN Spanning Tree) avec extension d'ID système.

---

## 8. Bannière de Connexion
```bash
banner motd ^C
***************************************************************************
*                   	Welcome to SportLudiques Network               	*
***************************************************************************
*                                                                     	*
*   	Authorized access only. All activities are monitored.         	*
*                                                                     	*
*  	"Empowering Sports and Fun with Every Connection!"             	*
*                                                                     	*
*   	For support, contact IT at: support@sportludiques.com         	*
*                                                                     	*
***************************************************************************
^C
```
- **Description** : Une bannière d'avertissement est définie pour informer les utilisateurs que l'accès est surveillé.

---

## 9. Appel au support Cisco (Call-Home)
### Service Call-Home
```bash
call-home
 contact-email-addr sch-smart-licensing@cisco.com
 profile "CiscoTAC-1"
  active
  destination transport-method http
```
- **Description** : La fonctionnalité Call-Home est activée pour envoyer des notifications au support Cisco.

---

## 10. Classement de Paquets et Politique de Contrôle
### Class-Maps et Policy-Map
```bash
class-map match-any system-cpp-police-ios-feature
 description ICMPGEN,BROADCAST,ICMP,L2LVXCntrl,ProtoSnoop,PuntWebauth,MCASTData,Transit,DOT1XAuth,Swfwd,LOGGING,L2LVXData,ForusTraffic,ForusARP,McastEndStn,Openflow,Exception,EGRExcption,NflSampled,RpfFailed
```
```bash
policy-map system-cpp-policy
```
- **Description** : Une série de `class-map` est utilisée pour classifier le trafic sur le switch, et une `policy-map` (nommée `system-cpp-policy`) gère les politiques de contrôle du plan de données (Control Plane Policing - CPP).

---

## 11. Configuration des Interfaces
### Interfaces Trunk (G1/0/1 à G1/0/24)
```bash
interface GigabitEthernet1/0/1
 switchport mode trunk
```
```bash
interface GigabitEthernet1/0/23
 switchport mode trunk
```
- **Description** : Les interfaces `GigabitEthernet1/0/1` à `GigabitEthernet1/0/24` sont configurées en mode trunk pour transporter le trafic de plusieurs VLANs.

---

## 12. Transceivers
```bash
transceiver type all
 monitoring
```
- **Description** : Les transceivers optiques sont surveillés pour tous les types de modules.

---

## 13. Services de Diagnostic
### Niveau minimal de démarrage
```bash
diagnostic bootup level minimal
```
- **Description** : Le diagnostic au démarrage est configuré sur le niveau `minimal` pour un démarrage plus rapide.

---

## Conclusion
Cette configuration offre une sécurité renforcée grâce à SSH et aux ACL, un contrôle rigoureux du routage et du trafic avec les `policy-maps`, et une gestion centralisée des VLANs et du spanning-tree. La configuration Call-Home assure également une surveillance proactive avec le support Cisco.
```

Cette documentation couvre toutes les commandes et configurations spécifiques que vous avez définies manuellement sur votre switch. Elle peut être facilement adaptée et complétée en fonction des besoins spécifiques de votre réseau.
