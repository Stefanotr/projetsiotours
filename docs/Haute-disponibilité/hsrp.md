# Configuration du HSRP pour les routeurs TRS-GW-01-FIBRE et TRS-GW-02-ADSL

## 1. Introduction

Le **HSRP** (Hot Standby Router Protocol) permet de configurer plusieurs routeurs pour partager une adresse IP virtuelle. Ce protocole assure une redondance et une continuité de service en cas de panne du routeur principal. Dans cette configuration, le routeur avec la priorité la plus élevée devient le routeur principal (actif), tandis que l'autre routeur prend le rôle de routeur de secours (standby).


## 2. Configuration du HSRP sur TRS-GW-01-FIBRE

Le routeur **TRS-GW-01-FIBRE** sera configuré comme **routeur principal** grâce à une priorité plus élevée (120). Voici la configuration :

```bash
conf t
interface GigabitEthernet0/0.224
 standby 1 ip 192.168.224.1
 standby 1 priority 120
 standby 1 preempt
exit
```

### Explications des commandes :
- **standby 1 ip 192.168.224.1** : Définit l'adresse IP virtuelle HSRP pour le VLAN 224. Cette adresse sera utilisée par les hôtes pour accéder au réseau, indépendamment de quel routeur est actif.
- **standby 1 priority 120** : Définit la priorité de **TRS-GW-01-FIBRE** à 120. Avec cette priorité, ce routeur sera le principal.
- **standby 1 preempt** : Permet à **TRS-GW-01-FIBRE** de reprendre son rôle de routeur principal en cas de rétablissement après une panne.

## 3. Configuration du HSRP sur TRS-GW-02-ADSL

Le routeur **TRS-GW-02-ADSL** sera configuré comme **routeur de secours** avec une priorité plus basse (115). Il prendra le relais si le routeur principal devient indisponible.

```bash
conf t
interface GigabitEthernet0/0.224
 standby 1 ip 192.168.224.1
 standby 1 priority 115
 standby 1 preempt
exit
```

### Explications des commandes :
- **standby 1 priority 115** : Définit la priorité de **TRS-GW-02-ADSL** à 115, ce qui le désigne comme routeur de secours.
- **standby 1 preempt** : Permet au routeur de reprendre son rôle en cas de retour de l'interface ou si le routeur principal (TRS-GW-01-FIBRE) est désactivé.

## 4. Vérification de la configuration HSRP

Pour vérifier que le HSRP est correctement configuré et opérationnel, exécutez la commande suivante sur les deux routeurs :

```bash
show standby
```

### Sortie typique :
Cette commande affichera les informations suivantes :
- L'adresse IP virtuelle HSRP (192.168.224.1)
- L'état du routeur (actif pour TRS-GW-01-FIBRE, standby pour TRS-GW-02-ADSL)
- Les priorités configurées
- Le temps de basculement (préemption)

## 5. Conclusion

Avec cette configuration, **TRS-GW-01-FIBRE** est le routeur principal avec une priorité de 120, tandis que **TRS-GW-02-ADSL** est le routeur de secours avec une priorité de 115. En cas de défaillance de **TRS-GW-01-FIBRE**, **TRS-GW-02-ADSL** prendra automatiquement le relais, garantissant une continuité du service. Une fois le routeur principal rétabli, il redeviendra automatiquement actif grâce à la fonctionnalité de préemption.