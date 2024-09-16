# Configuration de base des Switch

## 1. Configuration de Base

### Configuration du Nom d'Hôte

```bash
switch>en
switch#conf t
switch(config)# hostname Switch-Tours
```

### Configuration du Mot de Passe d'Accès Enable

```bash
Switch-Tours(config)# enable secret '#PASS#'
```

### Configuration de la Bannière MOTD

```bash
Switch-Tours(config)# banner motd $
***************************************************************************
*                      Welcome to SportLudiques Network                   *
***************************************************************************
*                                                                         *
*    Authorized access only. All activities are monitored.               *
*                                                                         *
*    "Empowering Sports and Fun with Every Connection!"                  *
*                                                                         *
*    For support, contact IT at: support@sportludiques.com               *
*                                                                         *
***************************************************************************
$
```

## 2. Configuration du VLAN d'Administration

### Création du VLAN 159 (admin)

```bash
Switch-Tours(config)# vlan 159
Switch-Tours(config-vlan)# name admin
```

### Configuration de l'Interface VLAN 159

```bash
Switch-Tours(config)# interface vlan 159
Switch-Tours(config-if)# ip address 172.28.159.XXX 255.255.255.0
Switch-Tours(config-if)# no shutdown
```

### Assignation du Port G1/0/24 en Mode Trunk

```bashur afficher les informations sur les interfaces réseau :

ip addr show

Pour vérifier la connectivité avec la passerelle :
Switch-Tours(config)# interface GigabitEthernet1/0/24
Switch-Tours(config-if)# switchport mode trunk
```

## 3. Configuration du SSH

### Activation du Service SSH

```bash
Switch-Tours(config)# ip domain-name sportludiques.com
Switch-Tours(config)# crypto key generate rsa
```

### Configuration de l'Utilisateur pour SSH

```bash
Switch-Tours(config)# username admin password Mot_de_passe_admin
```

### Configuration des Lignes VTY pour Utiliser SSH

```bash
Switch-Tours(config)# line vty 0 15
Switch-Tours(config-line)# transport input ssh
Switch-Tours(config-line)# login local
```

### Configuration des Accès SSH

```bash
Switch-Tours(config)# ip ssh version 2
```

## 4. Problèmes de Connexion SSH

Si vous rencontrez le message d'erreur suivant :

```
Unable to negotiate with 172.28.159.20 port 22: no matching key exchange method found. Their offer: diffie-hellman-group1-sha1*
```

Ajoutez la méthode d'échange de clés suivante à votre configuration SSH :

```plaintext
Host 172.28.159.20
    KexAlgorithms +diffie-hellman-group1-sha1
```