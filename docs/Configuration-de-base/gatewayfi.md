# 🌐 Configuration Avancée du Routeur **TRS-GW-01-FIBRE** 🚀

Ce guide vous accompagne pas à pas dans la configuration complète du routeur **TRS-GW-01-FIBRE**, couvrant les aspects de base, les interfaces, la sécurité SSH, le NAT, et le routage.

---

## 📋 **Objectif**

Configurer un routeur fiable et sécurisé pour une infrastructure réseau professionnelle.

---

## 🛠️ **Étape 1 : Configuration de Base**

### 🔧 Nom d'hôte

Définissez un nom d'hôte pour identifier le routeur dans le réseau :

```bash
conf t
hostname TRS-GW-01-FIBRE
exit
```

### 🔑 Mot de passe Mode Privilégié

Ajoutez un mot de passe pour sécuriser l'accès au mode privilégié :

```bash
enable secret VotreMotDePasseSécurisé
```

### 👤 Création d'un Utilisateur Administrateur

Créez un utilisateur avec des privilèges élevés et un accès SSH :

```bash
username admin privilege 15 secret VotreMotDePasseAdmin
```

### 💬 Message de Bienvenue (MOTD)

Ajoutez une bannière personnalisée pour informer les utilisateurs connectés :

<details>
<summary><strong>Afficher le message de bannière</strong></summary>

```bash
banner motd 
***************************************************************************
*               Bienvenue dans le Réseau de SportLudiques 🌟              *
***************************************************************************
*                                                                         *
*    ⚠️ Accès réservé. Toutes les activités sont surveillées.            *
*                                                                         *
*   ✉️ Support IT : support@sportludiques.com                             *
*                                                                         *
***************************************************************************
```
</details>

---

## 🌐 **Étape 2 : Configuration des Interfaces**

### 🌟 Interface VLAN Management (VLAN 220)

```bash
conf t
interface GigabitEthernet0/0.220
 encapsulation dot1Q 220
 ip address 10.10.10.1 255.255.255.0
 no shutdown
exit
```

#### Pourquoi un VLAN de management ?

Un VLAN de management isole le trafic de gestion réseau des autres trafics utilisateurs pour des raisons de sécurité, de surveillance et de fiabilité.

---

### 🌉 Interface VLAN Interconnexion (VLAN 224)

<details>
<summary><strong>Afficher la configuration de l'interface</strong></summary>

```bash
interface GigabitEthernet0/0.224
 encapsulation dot1Q 224
 ip address 192.168.224.2 255.255.255.0
 ip nat inside
 ip virtual-reassembly in
 no shutdown
exit
```
</details>

---

### 🌍 Interface WAN

```bash
conf t
interface GigabitEthernet0/1
 ip address 183.44.37.1 255.255.255.252
 ip nat outside
 ip virtual-reassembly in
 no shutdown
exit
```

---

## 🔒 **Étape 3 : Configuration de la Sécurité SSH**

### 🏷️ Nom de Domaine

Ajoutez un nom de domaine pour activer SSH :

```bash
ip domain-name sportludique.fr
```

### 🔐 Configuration SSH

```bash
conf t
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
exit
```

#### Pourquoi SSH et pas Telnet ?

SSH offre une connexion chiffrée et sécurisée, contrairement à Telnet qui transmet les données en clair. Les avantages incluent :
- **Sécurité renforcée** avec chiffrement des données.
- **Authentification par clé cryptographique** pour une meilleure protection.
- **Confidentialité totale** des commandes et données échangées.

---

## 🔄 **Étape 4 : Configuration du NAT**

### 📜 Configuration NAT

<details>
<summary><strong>Afficher la configuration complète du NAT</strong></summary>

```bash
conf t
access-list 1 permit 172.28.128.0 0.0.31.255
access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface GigabitEthernet0/1 overload
exit
```
</details>

#### Explication :
- **`ip nat inside source list 1 interface GigabitEthernet0/1 overload`** : Active le NAT avec surcharge pour traduire plusieurs adresses internes en une seule adresse publique.
- **`access-list 1 permit`** : Autorise les sous-réseaux spécifiés à utiliser le NAT.

---

## 🚦 **Étape 5 : Routage Statique**

### 🛣️ Ajoutez des Routes Statique

```bash
ip route 0.0.0.0 0.0.0.0 183.44.37.2
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0 255.255.0.0 192.168.224.254
exit
```

#### Explication :
- **Route par défaut :** `ip route 0.0.0.0 0.0.0.0 183.44.37.2` dirige le trafic sans destination spécifique vers l'internet.
- **Routes spécifiques :** Les routes pour `172.28.128.0/19` et `192.168.0.0/16` assurent que le trafic destiné à ces sous-réseaux est envoyé à `192.168.224.254`.

---

## 🧩 **Étape 6 : Validation et Tests**

### ✅ Vérification des Interfaces

Affichez les interfaces configurées :

```bash
show ip interface brief
```

### 🌐 Testez la Connectivité WAN

Testez la connectivité externe :

```bash
ping 8.8.8.8
```

### 🔄 Vérifiez les Traductions NAT

```bash
show ip nat translations
```

---

## 📚 **Conclusion**

Le routeur **TRS-GW-01-FIBRE** est maintenant configuré pour fournir une connectivité sécurisée, gérer le trafic interne et externe via NAT, et permettre une administration via SSH. 🌐🎉