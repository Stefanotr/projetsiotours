# Configuration avancée du routeur **TRS‑GW‑02‑ADSL**

## 1. Contexte : double liaison ADSL et redondance

Sportludique exploite un réseau d’entreprise exposé à de fortes variations de trafic, notamment lors d’événements en ligne et de sessions d’entraînement à distance. Pour garantir :

- **Continuité de service** – éviter toute interruption susceptible d’impacter les opérations commerciales et l’expérience utilisateur ;
- **Tolérance aux pannes** – assurer qu’une défaillance de la ligne principale n’interrompe pas l’accès au SI ;
- **Répartition de charge** – segmenter le trafic critique (paiement, VPN, supervision) du trafic de moindre priorité ;

le routeur TRS‑GW‑02‑ADSL est intégré avec **deux liaisons ADSL redondantes** (principale + secours). Le basculement est géré localement par route statique par défaut combinée à un suivi de connectivité (tracking) ; si la ligne primaire devient indisponible, la route par défaut est immédiatement replacée vers la ligne de secours.

---

## 2. Procédure de configuration

### 2.1 Configuration de base

```bash
conf t
hostname TRS-GW-02-ADSL
!
! Sécurisation du mode privilégié
enable secret <Secret_Privileged_Mode>
!
! Compte d’administration SSH
username admin privilege 15 secret <Secret_Admin>
!
! Bannière légale
banner motd ^
***************************************************************************
*          Accès réservé : toute activité est enregistrée et auditée.      *
*     Support IT : support@sportludique.com                                 *
***************************************************************************
^
exit
```

### 2.2 Configuration des interfaces

```bash
! VLAN Management (VLAN 220)
interface GigabitEthernet0/0.220
 encapsulation dot1Q 220
 ip address 10.10.10.2 255.255.255.0
 no shutdown
exit

! VLAN Interconnexion (VLAN 224)
interface GigabitEthernet0/0.224
 encapsulation dot1Q 224
 ip address 192.168.224.3 255.255.255.0
 ip nat inside
 no shutdown
exit

! Interface WAN (ADSL primaire)
interface GigabitEthernet0/1
 ip address 221.87.128.2 255.255.255.252
 ip nat outside
 no shutdown
exit
```

> **Remarque :** dupliquer la section WAN pour la seconde liaison ADSL si celle‑ci est raccordée sur une interface différente (ex. GigabitEthernet0/2).

### 2.3 Sécurisation SSH

```bash
ip domain-name sportludique.fr
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
exit
```

### 2.4 NAT et contrôle d’accès

```bash
! Réseaux internes autorisés à sortir
access-list 1 permit 172.28.128.0 0.0.31.255
access-list 1 permit 192.168.0.0   0.0.255.255
!
! Surcharge d’adresses (PAT) vers l’interface WAN
ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

### 2.5 Routage statique et basculement

```bash
! Route par défaut (liaison primaire)
ip route 0.0.0.0 0.0.0.0 221.87.128.1 track 10
!
! Route par défaut de secours (poids supérieur)
ip route 0.0.0.0 0.0.0.0 221.87.129.1 200
!
! Routage interne
ip route 172.28.128.0 255.255.224.0 192.168.224.254
ip route 192.168.0.0   255.255.0.0   192.168.224.254
```

### 2.6 Validation et tests

```bash
! État des interfaces
show ip interface brief

! Test de connectivité externe
ping 8.8.8.8 repeat 5

! Traductions NAT actives
show ip nat translations
```

---

## 3. Conclusion

La configuration ci‑dessus dote le routeur **TRS‑GW‑02‑ADSL** d’un environnement sécurisé, redondant et prêt pour la production :

- **Sécurité** assurée via l’authentification forte, le chiffrement SSH et un contrôle d’accès précis ;
- **Disponibilité** maximisée par la double liaison ADSL avec basculement automatique ;
- **Opérations** simplifiées grâce à un jeu de commandes de validation permettant de contrôler rapidement l’état du système.

Cette architecture garantit à Sportludique une connectivité résiliente, répondant aux exigences métiers tout en offrant une base évolutive pour les futures extensions du réseau.
