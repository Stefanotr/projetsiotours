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

## 4. Autres VLANs

### Création des VLANs avec leurs noms

<details>
<summary>Cliquez pour afficher la configuration des VLANs</summary>

```bash
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
 name (à définir)
!
vlan 224
 name Interconnexion
!
vlan 225
 name Production
!
vlan 226
 name Conception
```

</details>

### Création d'une Liste d'Accès SSH

L'ACL (Access Control List) étendue `ALLOW_SSH_VLAN220` a pour objectif de contrôler et sécuriser les accès SSH au réseau, en limitant l'accès aux seuls utilisateurs autorisés provenant du VLAN de management. Cette configuration permet de renforcer la sécurité en restreignant les connexions SSH à des sources spécifiques.

#### Configuration de l'ACL :
```bash
ip access-list extended ALLOW_SSH_VLAN220
 10 permit tcp 10.10.10.0 0.0.0.255 any eq 22
 20 deny   tcp any any eq 22
 30 permit ip any any
!
```

#### Explication :
- **Ligne 10** : Permet les connexions TCP sur le port 22 (SSH) uniquement depuis le sous-réseau `10.10.10.0/24`, correspondant au VLAN de management (VLAN 220). Cela garantit que seuls les administrateurs réseau peuvent accéder aux équipements via SSH depuis ce VLAN sécurisé.
- **Ligne 20** : Bloque toutes les autres connexions SSH provenant de n'importe quelle autre source, empêchant les accès non autorisés aux équipements réseau.
- **Ligne 30** : Permet tout autre trafic IP normal, en veillant à ce que le reste du trafic réseau ne soit pas perturbé par les restrictions SSH.

Cette ACL assure une protection contre les accès non autorisés aux services SSH, tout en permettant une gestion sécurisée du réseau via le VLAN de management. Elle contribue à réduire les risques d'intrusion en limitant l'accès à des adresses IP de confiance.

Pour afficher un titre suivi d'une liste de commandes qui peuvent être déroulées dans un fichier Markdown, tu peux utiliser une balise `<details>` pour créer une liste à dérouler. Voici comment structurer cette section avec cette fonctionnalité :

### Assignation des adresses IP et ACL sur les interfaces VLAN

<details>
<summary>Cliquez pour afficher la configuration des interfaces VLAN</summary>

```bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
!
interface Vlan221
 ip address 172.28.131.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
!
interface Vlan222
 ip address 192.168.37.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
!
interface Vlan224
 ip address 10.0.0.10 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
!
interface Vlan225
 ip address 172.28.135.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
!
interface Vlan226
 ip address 172.28.136.1 255.255.255.0
 ip access-group ALLOW_SSH_VLAN220 in
 no shutdown
```

</details>

### Description des VLANs
- **VLAN 220 - Management** : Ce VLAN est utilisé pour la gestion des équipements réseau. Il permet d'isoler le trafic de gestion (comme les accès SSH ou l'administration des équipements) du reste du réseau, garantissant ainsi une meilleure sécurité et stabilité.
  
- **VLAN 221 - Services** : Ce VLAN est dédié aux services critiques du réseau, tels que les serveurs d'applications, de bases de données ou d'authentification. Il assure une communication fiable et sécurisée entre les services essentiels.

- **VLAN 222 - DMZ** : Le VLAN DMZ est utilisé pour héberger des serveurs accessibles depuis l'extérieur, tels que les serveurs web ou mail. Il offre une zone de sécurité intermédiaire entre le réseau interne et l'extérieur, protégeant le réseau principal des attaques.

- **VLAN 223 - (à définir)** : Ce VLAN est encore à définir en fonction des besoins futurs ou des évolutions du réseau. Il pourrait être utilisé pour des services spécifiques ou pour des segments supplémentaires de l'infrastructure.

- **VLAN 224 - Interconnexion** : Ce VLAN permet d'assurer la communication entre différents segments du réseau ou avec des réseaux tiers. Il est souvent utilisé pour connecter plusieurs sites ou infrastructures, facilitant l'échange de données tout en maintenant une séparation logique du trafic.

- **VLAN 225 - Production** : Ce VLAN est réservé aux systèmes et services en environnement de production. Il est conçu pour fournir des performances optimales et une sécurité renforcée aux applications critiques de l'entreprise.

- **VLAN 226 - Conception** : Utilisé par les équipes de développement et d'ingénierie, ce VLAN permet de tester de nouvelles applications ou configurations sans impacter l'environnement de production. Il garantit une séparation nette entre les activités de conception et les systèmes en cours d'utilisation.

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