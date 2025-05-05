# Guide de configuration – IP SLA et suivi HSRP

## 1. Contexte : supervision proactive de la connectivité WAN

Dans l’architecture Sportludique, les routeurs **TRS‑GW‑01‑FIBRE** (actif) et **TRS‑GW‑02‑ADSL** (secours) utilisent HSRP pour fournir une passerelle virtuelle sur le VLAN 224. Pour garantir un basculement pertinent, il est indispensable d’évaluer en continu l’état réel des liaisons WAN :

| Plan | Objectif | Mécanisme |
|------|----------|-----------|
| Couche 3 | Adresse IP virtuelle et priorité | **HSRP** |
| Couche 3 | Santé de la route de sortie (ping passerelle FAI) | **IP SLA + Track** |

En associant IP SLA au suivi HSRP :

- le routeur **dissimule** les incidents liés à l’interface locale (up/down) ;
- le basculement s’enclenche si la **passerelle FAI** n’est plus joignable ;
- la priorité HSRP est **décrémentée dynamiquement** (–10) pour céder le rôle actif au routeur de secours.

---

## 2. Procédure de configuration

### 2.1 Routeur principal – **TRS‑GW‑01‑FIBRE**

```bash
! 1. Créer l’IP SLA n°1
ip sla 1
 icmp-echo 183.44.37.2 source-interface GigabitEthernet0/1
 frequency 30
exit
!
! 2. Planifier l’exécution en continu
ip sla schedule 1 life forever start-time now
!
! 3. Associer à un objet de suivi
track 1 ip sla 1 reachability
!
! 4. Lier le suivi au groupe HSRP sur le sous‑interface WAN interne
interface GigabitEthernet0/0.224
 standby 1 track 1 decrement 10
```

### 2.2 Routeur de secours – **TRS‑GW‑02‑ADSL**

```bash
ip sla 1
 icmp-echo 221.87.128.1 source-interface GigabitEthernet0/1
 frequency 30
exit
ip sla schedule 1 life forever start-time now
!
track 1 ip sla 1 reachability
!
interface GigabitEthernet0/0.224
 standby 1 track 1 decrement 10
```

> **Paramètres clés** :
> * `frequency 30` : intervalle de 30 s entre deux tests ICMP.
> * `decrement 10` : abaisse la priorité HSRP de 10 points si le suivi échoue.

### 2.3 Validation

```bash
# Statistiques IP SLA
show ip sla statistics

# État des objets de suivi
show track

# Rôle HSRP et priorité effective
show standby brief
```

---

## 3. Conclusion

La combinaison **IP SLA + Track** fournit une détection fine des coupures WAN ; elle complète HSRP pour assurer :

- un **basculement rapide** vers la passerelle de secours en cas de perte de connectivité vers le FAI ;
- un **retour automatique** au routeur fibre lorsque la liaison redevient opérationnelle ;
- une **continuité de service** perçue par les hôtes, sans modification de leur passerelle par défaut.

Cet ensemble renforce la résilience du réseau Sportludique face aux incidents de transport.
