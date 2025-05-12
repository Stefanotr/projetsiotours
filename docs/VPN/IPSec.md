# Guide de configuration – VPN IPsec site‑à‑site (pfSense)

## 1. Contexte : interconnexion sécurisée Bordeaux ↔ Tours

Suite au rachat d’une **agence à Bordeaux** et au lancement d’**E‑Sportludique**, l’entreprise doit relier son infrastructure centrale (site de Tours) au réseau de l’agence — tout en garantissant **confidentialité, intégrité et disponibilité** des données traversant Internet.

Exigences identifiées (Cahier des charges E6) :

| Objectif | Détail |
|----------|--------|
| **VPN chiffré** | Tunnel IPsec AES‑256 entre pare‑feux pfSense (VM) ; aucun service tiers requis |
| **Interopérabilité totale** | Les hôtes des deux LAN doivent communiquer comme sur un même réseau interne (services AD, ERP, sauvegardes) |
| **Fiabilité** | Le tunnel doit se ré‑établir automatiquement après coupure ; supervision dans les tableaux pfSense |
| **Coût maîtrisé** | Solutions open‑source / licences existantes ; déploiement internalisé |
| **Conformité BTS SIO** | Illustration des compétences : conception, déploiement, supervision (bloc ASR) |

Pourquoi IPsec ? Par rapport à SSL VPN ou GRE + IPsec :

- **Norme IETF** largement supportée : compatibilité routeurs, firewalls, clients natifs ;
- Mode **site‑à‑site** transparent (routage statique ou OSPF) ;
- Chiffrement **bout‑en‑bout** (IKEv2 + AES‑GCM) sans dépendance applicative ;
- Gestion fine des sous‑réseaux et des politiques de chiffrement.


## 2. Procédure de configuration



---

## 3. Conclusion

La liaison **IPsec site‑à‑site** offre :

- **Transparence** : utilisateurs, serveurs et téléphones IP échangent comme s’ils étaient sur le même LAN ;
- **Sécurité** : chiffrement AES‑256/ SHA‑256 + PFS, authentification réciproque par PSK ou certificats ;
- **Résilience** : reconnexion automatique après perte de lien ; monitoring visuel via l’onglet *Status › IPsec* de pfSense ;
- **Scalabilité** : possibilité d’ajouter d’autres sites (hub‑and‑spoke) ou des road‑warriors IKEv2 sans modifier l’architecture actuelle.

