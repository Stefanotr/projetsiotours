# Configuration du routeur TRS-GW-02-ADSL

Ce guide vous aidera à configurer un routeur **TRS-GW-02-ADSL** pour une infrastructure réseau sécurisée, incluant la configuration de base, les interfaces, la sécurité SSH, le NAT, et le routage.

## 1. Configuration de base

### Nom d'hôte (Hostname)

Le nom d'hôte est une étape fondamentale pour identifier le routeur dans le réseau. Utilisez la commande suivante pour configurer le nom d'hôte :

```bash
conf t
hostname TRS-GW-02-ADSL
exit
```

### Configuration d'un mot de passe pour accéder au mode privilégié

Pour sécuriser l'accès au mode **enable** :

```bash
enable secret password
```

### Création d'un utilisateur admin avec accès SSH

Ajoutez un utilisateur **admin** avec un privilège de niveau 15 et un accès SSH :

```bash
username admin privilege 15 secret admin
```

### Bannière (Message of the Day - MOTD)

Personnalisez une bannière d'accueil avec un message pour les utilisateurs qui se connectent au routeur :

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
<summary style="color: #007BFF;">Cliquez pour afficher la configuration de l'interface G0/0.220 (Management)</summary>

```bash
conf t
interface GigabitEthernet0/0.220
 encapsulation dot1Q 220
 ip address 10.10.10.2 255.255.255.0
 no shutdown
exit
```
</details>

##### Pourquoi un VLAN de management ?

Le **VLAN de management** est crucial pour isoler la gestion du réseau du trafic utilisateur. Voici les avantages :

- **Sécurité accrue** : Les communications de gestion sont isolées, rendant plus difficile l'accès non autorisé.
- **Meilleure surveillance** : Il est plus facile de surveiller et de contrôler l'accès aux équipements réseau.
- **Fiabilité** : Assure que les actions administratives ne perturbent pas le trafic réseau standard.

#### Interface d'interconnexion (VLAN 224)

<details>
<summary style="color: #007BFF;">Cliquez pour afficher la configuration de l'interface G0/0.224 (Interconnexion)</summary>

```bash
interface GigabitEthernet0/0.224
 encapsulation dot1Q 224
 ip address 192.168.224.3 255.255.255.0
 ip nat inside
exit
```
</details>

### 2.2 Interface GigabitEthernet0/1

Cette interface est utilisée pour la connectivité externe :

```bash
conf t
interface GigabitEthernet0/1
 ip address 221.87.128.2 255.255.255.252
 ip nat outside
exit
```

## 3. Configuration du nom de domaine et de l'accès SSH

### Configuration du Domaine

Définissez le nom de domaine pour faciliter l'accès SSH :

```bash
ip domain-name sportludique.fr
```

### Configuration SSH

```bash
conf t
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
exit
```

#### Pourquoi SSH et pas Telnet ?

**SSH** (Secure Shell) offre une communication sécurisée et chiffrée entre l'administrateur et l'équipement réseau, contrairement à **Telnet** qui transmet les informations en texte clair. Voici les principaux avantages de SSH :

- **Sécurité renforcée** : Toutes les communications sont chiffrées, empêchant les interceptions.
- **Authentification par clé** : Possibilité d'utiliser des clés cryptographiques pour sécuriser l'accès.
- **Confidentialité** : SSH assure que les commandes exécutées restent privées.

## 4. Configuration du NAT et des routes statiques

### 4.1 NAT (Network Address Translation)

#### Qu'est-ce que le NAT ?

Le **NAT** masque les adresses IP internes en les traduisant en une adresse publique, permettant aux appareils internes de communiquer avec des réseaux externes sans exposer leurs adresses privées.

##### Avantages du NAT :
- **Masquage des adresses internes** pour une sécurité accrue.
- **Réduction de l'utilisation des adresses IP publiques** en traduisant plusieurs adresses privées en une seule adresse publique.
- **Flexibilité du réseau** en facilitant l'intégration avec les réseaux publics.

#### Configuration du NAT

```bash
conf t
ip nat inside source list 1 interface GigabitEthernet0/1 overload
access-list 1 permit 172.28.128.0 0.0.31.255
access-list 1 permit 192.168.0.0 0.0.255.255
exit
```

##### Explication des commandes :

- **ip nat inside source list 1 interface GigabitEthernet0/1 overload** : Active le NAT avec surcharge pour traduire plusieurs adresses internes en une adresse publique.
- **access-list 1 permit** : Autorise les sous-réseaux à utiliser le NAT.

### 4.2 Routage IP

Les **routes statiques** permettent au routeur de diriger le trafic en fonction de la destination.

#### Configuration des Routes Statiques

```bash
ip route 0.0.0.0 0.0.0.0 221.87.128.1
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0 255.255.0.0 192.168.224.254
exit
```

##### Explication des routes :
- **ip route 0.0.0.0 0.0.0.0 221.87.128.1** : Route par défaut pour le trafic sans destination définie.
- **ip route 172.28.128.0 255.255.224.0** : Route spécifique pour le sous-réseau 172.28.128.0.
- **ip route 192.168.0.0 255.255.0.0** : Route spécifique pour le sous-réseau 192.168.0.0.

---

<style>
code {
  background-color: #f4f4f4;
  color: #333;
  padding: 5px;
  border-radius: 5px;
}
pre {
  background-color: #272822;
  color: #f8f8f2;
  padding: 15px;
  border-radius: 10px;
}
h1, h2, h3 {
  color: #007BFF;
}
summary {
  color: #007BFF;
  font-weight: bold;
}
details {
  margin-bottom: 10px;
}
</style>