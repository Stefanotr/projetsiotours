# Guide de configuration – Agrégation de liens (LACP)

## 1. Contexte : agrégation entre **TRS‑SW‑CORE** et l’hyperviseur Proxmox

Pour fournir à la plateforme de virtualisation Proxmox un accès réseau **haut débit** et **tolérant aux pannes**, deux liaisons Gigabit (*Gi1/0/18* et *Gi1/0/19*) du switch **TRS‑SW‑CORE** sont agrégées via **LACP** dans le **Port‑channel 1**. Ce lien logique, présenté côté Proxmox sous forme de bond 802.3ad, permet :

- **Addition de la bande passante** : cumule le débit des liens physiques ;
- **Basculage automatique** : maintien de la connectivité si un câble ou un transceiver tombe ;
- **Transport multi‑VLAN** : chaque réseau (management, production, DMZ…) reste isolé tout en partageant la même paire de fibres.

Cette architecture élimine les points de défaillance uniques entre le cœur et l’hyperviseur tout en simplifiant la configuration IP côté Proxmox.

---

## 2. Procédure de configuration

### 2.1 Création de l’interface logique

```bash
interface Port-channel1
 description Uplink_Proxmox_Agreg
 switchport mode trunk            # Transporte les VLAN utilisés par les VMs
 ! Optionnel : limiter la liste des VLAN
 ! switchport trunk allowed vlan 125,220-229
```

### 2.2 Ajout des interfaces physiques

```bash
interface GigabitEthernet1/0/18
 description Proxmox_LACP_1
 switchport mode trunk
 channel-group 1 mode active       # Négociation LACP
!
interface GigabitEthernet1/0/19
 description Proxmox_LACP_2
 switchport mode trunk
 channel-group 1 mode active       # Négociation LACP
```

### 2.3 Validation

```bash
# Afficher la configuration du Port-channel
show run interface Port-channel1

# Vérifier l’état LACP et les membres
show etherchannel summary
```

---

## 3. Conclusion

L’agrégation LACP entre **TRS‑SW‑CORE** et Proxmox offre :

- **Débit agrégé** correspondant à la somme des interfaces membres ;
- **Continuité de service** grâce au basculement instantané sur le lien restant ;
- **Gestion unifiée** avec un seul Port‑channel côté switch et un bond 802.3ad côté hyperviseur.

Cette configuration garantit des performances réseau optimales pour l’ensemble des machines virtuelles tout en renforçant la disponibilité de l’infrastructure.
