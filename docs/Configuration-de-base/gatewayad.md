# 🌐 Configuration Avancée du Routeur **TRS-GW-02-ADSL** 🚀

Ce guide couvre la configuration complète du routeur **TRS-GW-02-ADSL**, incluant la configuration de base, la gestion des interfaces, la sécurité, le NAT, et le routage IP.

---

## 📋 **Objectif**

Configurer un routeur sécurisé et fonctionnel pour répondre aux besoins d'un réseau d'entreprise.

---

## 🛠️ **Étape 1 : Configuration de Base**

### 🔧 Nom d'hôte

Définissez un nom d'hôte pour identifier le routeur dans le réseau :

```bash
conf t
hostname TRS-GW-02-ADSL
exit
```

### 🔑 Mot de passe Mode Privilégié

Pour sécuriser l'accès au mode privilégié :

```bash
enable secret VotreMotDePasseSécurisé
```

### 👤 Création d'un Utilisateur Administrateur

Créez un utilisateur avec des privilèges élevés pour la gestion SSH :

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
 ip address 10.10.10.2 255.255.255.0
 no shutdown
exit
```

### 🌉 Interface VLAN Interconnexion (VLAN 224)

```bash
interface GigabitEthernet0/0.224
 encapsulation dot1Q 224
 ip address 192.168.224.3 255.255.255.0
 ip nat inside
 no shutdown
exit
```

### 🌍 Interface WAN

```bash
interface GigabitEthernet0/1
 ip address 221.87.128.2 255.255.255.252
 ip nat outside
 no shutdown
exit
```

---

## 🔒 **Étape 3 : Configuration de la Sécurité SSH**

### 🏷️ Nom de Domaine

Définissez un nom de domaine pour activer SSH :

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

---

## 🔄 **Étape 4 : Configuration du NAT**

<details>
<summary><strong>📜 Configuration complète du NAT</strong></summary>

Ajoutez une liste d'accès et configurez le NAT :

```bash
conf t
access-list 1 permit 172.28.128.0 0.0.31.255
access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface GigabitEthernet0/1 overload
exit
```
</details>

---

## 🚦 **Étape 5 : Routage Statique**

Ajoutez des routes pour le trafic réseau :

```bash
conf t
ip route 0.0.0.0 0.0.0.0 221.87.128.1
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0 255.255.0.0 192.168.224.254
exit
```

---

## 🧩 **Étape 6 : Validation et Tests**

### ✅ Vérification des Interfaces

Affichez les interfaces configurées :

```bash
show ip interface brief
```

### 🌐 Testez la Connectivité WAN

Vérifiez la connectivité externe :

```bash
ping 8.8.8.8
```

### 🔄 Vérifiez les Traductions NAT

```bash
show ip nat translations
```

---

## 📚 **Conclusion**

Le routeur **TRS-GW-02-ADSL** est maintenant configuré pour fournir une connectivité sécurisée, gérer le trafic interne et externe via NAT, et permettre une administration via SSH. 🌐🎉