# 🌐 Configuration Avancée du Switch Core **SW-core-tours** 🚀

## 📘 **Description d’un Switch Cœur**

Un switch cœur, comme son nom l’indique, constitue le **noyau central** d’une architecture réseau. Il joue un rôle clé dans l’acheminement et l’agrégation des données entre les différents switchs de distribution, les serveurs, et les autres équipements connectés. 

### 🛡️ Fonctionnalités clés :
1. **Haute performance :** Supporte un trafic intensif avec des vitesses de transfert élevées.
2. **Routage Inter-VLAN :** Assure la communication entre les VLANs.
3. **Redondance et fiabilité :** Permet des configurations de haute disponibilité avec des protocoles comme HSRP ou VRRP.
4. **Évolutivité :** Facilite l’intégration de nouveaux équipements ou extensions du réseau.

### 🔄 Différence avec un switch de distribution :
- **Switch cœur :** Optimisé pour le traitement et l'acheminement rapide du trafic global.
- **Switch de distribution :** Connecte les périphériques utilisateurs et applique les politiques réseau (comme les ACL ou QoS).

## 🛠️ **1. Configuration de Base**

### 🔧 Nom d'Hôte

Définissez le nom d'hôte pour identifier clairement le switch :

bash
hostname SW-core-tours



### 🔑 Mot de Passe Mode Privilégié

Sécurisez l'accès au mode privilégié :

bash
enable secret VotreMotDePasseSécurisé



### 👤 Création d’un Utilisateur Administrateur

Créez un utilisateur avec des privilèges élevés et un accès SSH :

bash
username admin privilege 15 secret VotreMotDePasseAdmin



### 💬 Message de Bienvenue (MOTD)

Ajoutez une bannière d'avertissement pour les connexions au switch :

bash
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



---

## 🌟 **2. VLAN de Management (VLAN 220)**

### Configuration du VLAN de Management

bash
interface Vlan220
 ip address 10.10.10.10 255.255.255.0
 no shutdown



### 🔒 Pourquoi un VLAN de Management ?

- **Sécurité accrue :** Isole les communications de gestion pour limiter les accès non autorisés.
- **Surveillance :** Simplifie la détection d'activités suspectes.
- **Fiabilité :** Assure que les modifications administratives n’affectent pas le trafic utilisateur.

---

## 🔒 **3. Domaine et Sécurité SSH**

### 🏷️ Configuration du Domaine

bash
ip domain-name sportludique.fr



### 🔐 Configuration SSH

bash
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh



#### Pourquoi SSH et pas Telnet ?

- **Sécurité :** Chiffrement des données pour empêcher les interceptions.
- **Confidentialité :** Toutes les commandes et données échangées sont protégées.
- **Authentification :** Possibilité d’utiliser des clés pour renforcer la sécurité.

---

## 🌐 **4. Autres VLANs**

### 📂 Liste des VLANs

<details>
<summary><strong>Afficher la configuration des VLANs</strong></summary>

<pre>
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
</pre>

</details>

### 🎯 Description des VLANs

- **VLAN 220 - Management :** Administration réseau sécurisée.
- **VLAN 221 - Services :** Applications critiques.
- **VLAN 222 - DMZ :** Serveurs accessibles depuis l’extérieur.
- **VLAN 223 :** À définir.
- **VLAN 224 - Interconnexion :** Communication entre segments ou sites.
- **VLAN 225 - Production :** Services critiques de production.
- **VLAN 226 - Conception :** Environnement de test et développement.

---

## 🚦 **5. Routage IP**

### Activation du Routage

bash
ip routing



### Ajout de la Route par Défaut

bash
ip route 0.0.0.0 0.0.0.0 10.0.0.1



#### Description

Le routage IP permet la communication entre les VLANs et le réseau extérieur. La route par défaut dirige le trafic inconnu vers le routeur principal (10.0.0.1).

---

## 🔄 **6. Configuration des Ports**

### 🛠️ Ports en Mode Trunk

<details>
<summary><strong>Afficher la configuration des ports Trunk</strong></summary>

<pre>
interface GigabitEthernet1/0/24
 switchport mode trunk
 no shutdown
!
interface GigabitEthernet1/0/23
 switchport mode trunk
 no shutdown
!
interface GigabitEthernet1/0/22
 switchport mode trunk
 no shutdown
!
interface GigabitEthernet1/0/2
 switchport mode trunk
 no shutdown
!
interface GigabitEthernet1/0/1
 switchport mode trunk
 no shutdown
</pre>

</details>

---

## 📚 **Conclusion**

La configuration du switch **SW-core-tours** garantit une connectivité réseau robuste et fiable. En tant que switch cœur, il gère l'agrégation et le routage du trafic tout en offrant une sécurité et une performance optimales pour l'infrastructure de SportLudiques. 🌐🎉'est ca mon css pour le rendu genre quand tu afihce les vlan c'est la balise pre qu'il faut mettre.