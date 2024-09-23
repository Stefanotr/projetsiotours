# Configuration du Switch core

## 1. Configuration de base (du nom d'hôte et d'un utilisateur pour le SSH)

### Nom d'hôte
```bash
hostname SW-core-tours
```

### Configuration d'un mot de passe pour acceder au mode priviliéger
```bash
enable secret password
```

### Création d'un utilisateur admin avec accès SSH

```bash
username admin privilege 15 secret admin
```

### Configuration de la bannière de message du jour (MOTD)

```bash
banner motd 
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
```

Voici une description expliquant l'importance d'un VLAN de management pour la sécurité, intégrée dans la documentation en Markdown :

## 2. VLAN de management (VLAN 220)

### Configuration du VLAN 220
```bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 no shutdown
```

### Pourquoi un VLAN de management ?

Le VLAN de management est crucial pour isoler la gestion du réseau des autres trafics utilisateur. Voici les principales raisons de son importance :

- **Sécurité accrue** : En isolant les communications de gestion du reste du réseau, il devient plus difficile pour des utilisateurs non autorisés d'accéder aux équipements réseau. Cela réduit le risque de compromission.
  
- **Meilleure surveillance** : Le VLAN de management permet de suivre et de contrôler plus facilement les accès aux équipements réseau, facilitant ainsi la détection des activités suspectes.

- **Fiabilité et stabilité** : Le fait d’avoir un VLAN dédié à la gestion des équipements assure que les modifications, mises à jour et autres actions administratives ne sont pas perturbées par le trafic réseau standard.

## 3. Domaine et SSH

### Configuration du Domaine
```bash
ip domain-name example.com
```

### Configuration SSH
```bash
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
```

---

### Pourquoi SSH et pas Telnet ?

**SSH (Secure Shell)** est un protocole de gestion à distance sécurisé qui crypte toutes les communications entre un administrateur et un équipement réseau. Contrairement à **Telnet**, qui transmet les données (y compris les mots de passe) en texte clair, SSH garantit que toutes les informations échangées sont chiffrées et protégées des interceptions.

Les avantages principaux de SSH sont :
- **Sécurité renforcée** : SSH chiffre toutes les données, ce qui empêche les attaques de type "man-in-the-middle" ou l'espionnage des informations sensibles telles que les mots de passe.
  
- **Authentification** : Avec SSH, il est possible d'utiliser des clés cryptographiques pour l'authentification, ce qui renforce encore plus la sécurité.

- **Confidentialité** : SSH assure que toutes les commandes exécutées et les données échangées restent privées.

En résumé, SSH est essentiel pour administrer les équipements en toute sécurité, là où Telnet représente un risque de sécurité majeur en raison de l'absence de chiffrement.


## 4. Autres VLANs

### Création des VLANs avec leurs noms

```bash
vlan 220
 name Management
!
vlan 221
 name Services
!
vlan 222
 name Prod
!
vlan 223
 name Conception
!
vlan 224
 name WIFI
```

#### Description des VLANs
- **VLAN 220 - Management** : Utilisé pour la gestion des équipements réseau, assurant que l'accès à la gestion est isolé du trafic utilisateur pour des raisons de sécurité.
  
- **VLAN 221 - Services** : Destiné aux services de réseau essentiels, comme les serveurs d'application ou de base de données, permettant une communication efficace et sécurisée.

- **VLAN 222 - Prod** : Réservé aux environnements de production, ce VLAN gère le trafic des systèmes en production, garantissant des performances optimales.

- **VLAN 223 - Conception** : Utilisé pour le développement et les tests, permettant aux équipes de travailler sur des projets sans interférer avec les environnements de production.

- **VLAN 224 - WIFI** : Destiné à la connectivité sans fil, ce VLAN permet aux utilisateurs mobiles de se connecter au réseau tout en maintenant une séparation des autres types de trafic.

### Assignation des adresses IP
```bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 no shutdown
!
interface Vlan221
 ip address 172.28.131.1 255.255.255.0
 no shutdown
!
interface Vlan222
 ip address 172.28.132.1 255.255.255.0
 no shutdown
!
interface Vlan223
 ip address 172.28.133.1 255.255.255.0
 no shutdown
!
interface Vlan224
 ip address 172.28.134.1 255.255.255.0
 no shutdown
```

## 5. Routage IP

### Activation du Routage
```bash
ip routing
```

#### Description
L'activation du routage IP sur un commutateur permet à celui-ci de transférer les paquets entre différents VLANs et de gérer la communication entre les réseaux. Cela est essentiel pour assurer que les données peuvent circuler efficacement à travers l'infrastructure réseau, en permettant aux appareils de différents VLANs de communiquer entre eux.

### Ajout de la Route par Défaut
```bash
ip route 0.0.0.0 0.0.0.0 10.0.0.1
```

#### Description de la Route par Défaut
La route par défaut configure le commutateur pour diriger tout le trafic destiné à un réseau non spécifié vers l'adresse IP `10.0.0.1`, qui est le routeur HSRP de Tours. Cela garantit que, même si le commutateur ne connaît pas la destination d'un paquet, il peut toujours acheminer le trafic vers le routeur principal pour traitement. Cela aide à maintenir la connectivité réseau et à éviter les pannes de communication.

## 6. Configuration des Ports

### Ports en mode Trunk
```bash
interface GigabitEthernet0/1
 switchport mode trunk
 no shutdown
!
interface GigabitEthernet0/2
 switchport mode trunk
 no shutdown
```

### Ports en mode Access
```bash
interface GigabitEthernet0/3
 switchport mode access
 switchport access vlan 221
 no shutdown
!
interface GigabitEthernet0/4
 switchport mode access
 switchport access vlan 222
 no shutdown
!
interface GigabitEthernet0/5
 switchport mode access
 switchport access vlan 223
 no shutdown
```

---