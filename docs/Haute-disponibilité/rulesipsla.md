# Document sur IP SLA

## Qu'est-ce que IP SLA ?

**IP SLA** (Service Level Agreement) est une fonctionnalité des routeurs Cisco qui permet de surveiller les performances et la disponibilité des réseaux. Il utilise divers protocoles, tels que ICMP (ping), pour effectuer des tests de connectivité et d'autres vérifications de services.

## Pourquoi utiliser IP SLA ?

L'utilisation d'IP SLA offre plusieurs avantages :

- **Surveillance proactive** : Permet de vérifier en continu la disponibilité des ressources réseau, comme les passerelles et les serveurs.
- **Détection de pannes** : Identifie rapidement les problèmes de connectivité, ce qui permet une réponse rapide.
- **Intégration avec HSRP** : IP SLA peut être intégré avec HSRP (Hot Standby Router Protocol) pour basculer automatiquement entre les routeurs en cas de défaillance.

## Configuration d'IP SLA pour surveiller la connectivité WAN

### Objectif

L'objectif ici est de configurer IP SLA pour qu'il ping une passerelle (par exemple, `183.44.37.2`) toutes les 30 secondes. Si la passerelle ne répond pas, la priorité du routeur associé sera diminuée de 10, ce qui pourrait entraîner un basculement HSRP.

### Étapes de Configuration

#### Sur Routeur 1 (TRS-GW-01-FIBRE)

1. **Configurer IP SLA** :
```bash
   Router1(config)# ip sla 1
   Router1(config-ip-sla)# icmp-echo 183.44.37.2 source-interface g0/1
   Router1(config-ip-sla)# frequency 30
   Router1(config-ip-sla)# exit
   Router1(config)# ip sla schedule 1 life forever start-time now
```

2. **Configurer le suivi IP SLA** :
```bash
   Router1(config)# track 1 ip sla 1 reachability
   Router1(config)# interface g0/0.224
   Router1(config-if)# standby 1 track 1 decrement 10
```

#### Sur Routeur 2 (TRS-GW-02-ADSL)

1. **Configurer IP SLA** :
```bash
   Router2(config)# ip sla 1
   Router2(config-ip-sla)# icmp-echo 221.87.128.1 source-interface g0/1
   Router2(config-ip-sla)# frequency 30
   Router2(config-ip-sla)# exit
   Router2(config)# ip sla schedule 1 life forever start-time now
```

2. **Configurer le suivi IP SLA** :
```bash
   Router2(config)# track 1 ip sla 1 reachability
   Router2(config)# interface g0/0.224
   Router2(config-if)# standby 1 track 1 decrement 10
```

### Explication des Commandes

- **`ip sla <id>`** : Crée une instance d'IP SLA.
- **`icmp-echo <ip> source-interface <interface>`** : Configure un test ICMP à destination d'une adresse IP à partir d'une interface spécifique.
- **`frequency <value>`** : Définit la fréquence à laquelle le test est exécuté (en secondes).
- **`track <track-id> ip sla <sla-id> reachability`** : Lie une instance d'IP SLA à un objet de suivi.
- **`standby <group> track <track-id> decrement <value>`** : Diminue la priorité HSRP si le suivi échoue.

## Vérification de la Configuration

Pour vérifier l'état de l'IP SLA et des suivis, utilisez les commandes suivantes :

```bash
    Router1# show ip sla statistics
    Router2# show ip sla statistics
    Router1# show track
    Router2# show track
```

## Conclusion

IP SLA est un outil puissant pour surveiller la connectivité WAN. Couplé à HSRP, il permet de garantir une redondance et une continuité de service, même en cas de défaillance des interfaces WAN.