# Configuration du routeur TRS-GW-01-FIBRE

## 1. Configuration de base

### Nom d'hôte (Hostname)
Le nom d'hôte est une étape fondamentale pour identifier le routeur dans le réseau. Voici la commande pour le configurer :

```bash
conf t
hostname TRS-GW-01-FIBRE
exit
```

### Configuration d'un mot de passe pour acceder au mode priviliéger
```bash
enable secret password
```

### Création d'un utilisateur admin avec accès SSH

```bash
username admin privilege 15 secret admin
```

### Bannière (Message of the Day - MOTD)
Vous pouvez configurer un message de bannière qui s'affichera à chaque connexion au routeur.

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

## 2. Configuration des interfaces

### 2.1 Interface GigabitEthernet0/0

#### Interface de management (VLAN 220)

<details>
<summary>Cliquez pour afficher la configuration de l'interface G0/0.220 (Management)</summary>

```bash
conf t
interface GigabitEthernet0/0.220
 encapsulation dot1Q 220
 ip address 10.10.10.1 255.255.255.0
 no shutdown
exit
```

</details>

##### Pourquoi un VLAN de management ?

Le VLAN de management est crucial pour isoler la gestion du réseau des autres trafics utilisateur. Voici les principales raisons de son importance :

- **Sécurité accrue** : En isolant les communications de gestion du reste du réseau, il devient plus difficile pour des utilisateurs non autorisés d'accéder aux équipements réseau. Cela réduit le risque de compromission.
  
- **Meilleure surveillance** : Le VLAN de management permet de suivre et de contrôler plus facilement les accès aux équipements réseau, facilitant ainsi la détection des activités suspectes.

- **Fiabilité et stabilité** : Le fait d’avoir un VLAN dédié à la gestion des équipements assure que les modifications, mises à jour et autres actions administratives ne sont pas perturbées par le trafic réseau standard.

#### Interface d'inter-connexion (VLAN 224)

<details>
<summary>Cliquez pour afficher la configuration de l'interface G0/0.224 (Inter-connexion)</summary>

```bash
interface GigabitEthernet0/0.224
  encapsulation dot1Q 224
  ip address 192.168.224.2 255.255.255.0
  ip nat inside
  ip virtual-reassembly in
  exit
```

</details>

### 2.2 Interface GigabitEthernet0/1
L'interface `GigabitEthernet0/1` est utilisée pour la connectivité externe.

```bash
conf t
interface GigabitEthernet0/1
 ip address 183.44.37.1 255.255.255.252
 ip nat outside
 ip virtual-reassembly in
exit
```

## 3. Configuration du nom de domaine et de l'accès SSH

### Configuration du Domaine
```bash
ip domain-name example.com
```

### Configuration SSH

```bash
conf t
ip domain-name sportludique.fr
ip ssh version 2
username admin privilege 15 secret motdepasseadmin
line vty 0 4
 login local
 transport input ssh
exit
```

### Pourquoi SSH et pas Telnet ?

**SSH (Secure Shell)** est un protocole de gestion à distance sécurisé qui crypte toutes les communications entre un administrateur et un équipement réseau. Contrairement à **Telnet**, qui transmet les données (y compris les mots de passe) en texte clair, SSH garantit que toutes les informations échangées sont chiffrées et protégées des interceptions.

Les avantages principaux de SSH sont :
- **Sécurité renforcée** : SSH chiffre toutes les données, ce qui empêche les attaques de type "man-in-the-middle" ou l'espionnage des informations sensibles telles que les mots de passe.
  
- **Authentification** : Avec SSH, il est possible d'utiliser des clés cryptographiques pour l'authentification, ce qui renforce encore plus la sécurité.

- **Confidentialité** : SSH assure que toutes les commandes exécutées et les données échangées restent privées.

## 4. Configuration du NAT et des routes statiques

### 4.1 NAT
#### Qu'est-ce que le NAT (Network Address Translation) ?

Le **NAT** (Network Address Translation) est une technique utilisée pour masquer les adresses IP internes du réseau lorsqu'elles accèdent à des ressources externes, comme l'internet. Le NAT traduit les adresses IP privées des appareils locaux en une adresse IP publique, ce qui permet de conserver les adresses internes privées tout en permettant la communication avec l'extérieur.

##### Avantages du NAT
- **Masquage des adresses internes** : Le NAT cache les adresses IP internes, augmentant ainsi la sécurité en rendant ces adresses invisibles depuis l'extérieur.
- **Économie d'adresses IP publiques** : Plusieurs adresses IP internes peuvent être traduites en une seule adresse IP publique, permettant de gérer de nombreux appareils sans avoir à utiliser une adresse IP publique pour chacun.
- **Flexibilité du réseau** : Le NAT permet aux réseaux utilisant des adresses IP privées d'interagir avec des réseaux publics sans conflit d'adresses IP.

#### Configuration du NAT

```bash
conf t
 ip nat inside source list 1 interface GigabitEthernet0/1 overload
 access-list 1 permit 172.28.128.0 0.0.31.255
 access-list 1 permit 192.168.0.0 0.0.255.255
exit
```

##### Explication :
- **ip nat inside source list 1 interface GigabitEthernet0/1 overload** : Active le NAT sur l'interface GigabitEthernet0/1 en utilisant la surcharge (overload), ce qui permet de traduire plusieurs adresses internes en une seule adresse IP publique.
- **access-list 1 permit 172.28.128.0 0.0.31.255** : Autorise les adresses du sous-réseau `172.28.128.0/19` (de `172.28.128.0` à `172.28.159.255`) à utiliser le NAT.
- **access-list 1 permit 192.168.0.0 0.0.255.255** : Autorise les adresses du sous-réseau `192.168.0.0/16` à utiliser le NAT.

### 4.2 Routage IP

Le routage IP permet au routeur de transférer les paquets entre différents réseaux. Le routeur utilise des **routes statiques** ou dynamiques pour savoir où diriger les paquets en fonction de leur destination.

#### Configuration des Routes Statiques

```bash
ip route 0.0.0.0 0.0.0.0 183.44.37.2
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0 255.255.0.0 192.168.224.254
exit
```

##### Explication :
- **ip route 0.0.0.0 0.0.0.0 183.44.37.2** : Définit une route par défaut, ce qui signifie que tout le trafic qui n'a pas de route spécifique définie sera envoyé vers l'adresse IP `183.44.37.2`. C'est généralement l'adresse IP d'un routeur connecté à l'internet.
- **ip route 172.28.128.0 255.255.224.0 192.168.224.254** : Crée une route statique pour le sous-réseau `172.28.128.0/19`, dirigeant le trafic destiné à ce réseau vers l'adresse IP du prochain saut `192.168.224.254`.
- **ip route 192.168.0.0 255.255.0.0 192.168.224.254** : Crée une route statique pour le réseau `192.168.0.0/16`, dirigeant le trafic destiné à ce réseau vers `192.168.224.254`.
