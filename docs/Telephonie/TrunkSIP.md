# Guide de configuration – Trunk SIP inter‑sites Entreprise ↔ Agence

## 1. Contexte : téléphonie unifiée et optimisation des coûts

La mise en place du tunnel **IPsec** entre le siège de Sportludique (Tours) et l’agence de Bordeaux permet désormais de faire circuler le trafic en toute sécurité. Pour aller plus loin, l’entreprise souhaite :

- **Unifier les communications internes** : appeler un collaborateur à Bordeaux doit être aussi simple qu’un appel interne au siège ;
- **Réduire les coûts** : supprimer les appels sortants via l’opérateur pour le trafic inter‑sites ;
- **Simplifier l’exploitation** : un seul plan de numérotation;
- **Préparer la montée en charge** : la solution doit pouvoir intégrer d’autres agences à moyen terme.

Un **trunk SIP privé** entre les deux IPBX Asterisk répond à ces enjeux : le signalisation SIP et le média RTP passent à travers le tunnel IPsec, sans exposition sur Internet.

---

## 2. Procédure de configuration

> Les blocs ci‑dessous sont à insérer tels quels dans vos fichiers `sip.conf` et `extensions.conf`et de les modifier à vos besoins.

### 2.1 IPBX Entreprise (Tours)

#### 2.1.1 `/etc/asterisk/sip.conf`
```ini
;--------------------------------------------------
; TRUNK SIP sortant / entrant vers le PBX Agence
;--------------------------------------------------
[agence-trunk]
type=peer
host=10.0.128.135            ; IP fixe du serveur Agence
context=from-agence          ; contexte où arrivent SES appels
disallow=all
allow=ulaw
allow=alaw
directmedia=yes              ; RTP direct : utile car pas de NAT
insecure=port,invite         ; pas d’authentification (labo)
qualify=yes                  ; ping SIP toutes les 60 s
```

#### 2.1.2 `/etc/asterisk/extensions.conf`
```ini
include => outgoing-agence

;---------------------------------------------------------------------
;  SORTANT – tout 7xx ou 8xx (3 chiffres) part vers le trunk Agence
;---------------------------------------------------------------------
[outgoing-agence]
exten => _7XX,1,NoOp(Envoi ${EXTEN} vers Agence via trunk)
 same  => n,Dial(SIP/${EXTEN}@agence-trunk)
 same  => n,Hangup()

exten => _8XX,1,NoOp(Envoi ${EXTEN} vers Agence via trunk)
 same  => n,Dial(SIP/${EXTEN}@agence-trunk)
 same  => n,Hangup()

;---------------------------------------------------------------------
;  ENTRANT – appels reçus du trunk Agence
;---------------------------------------------------------------------
[from-agence]
exten => _7XXX,1,NoOp(Appel entrant de l’Agence vers ${EXTEN})
 same  => n,Dial(SIP/${EXTEN},15)
 same  => n,Playback(vm-nobodyavail)
 same  => n,VoiceMail(${EXTEN}@main)
 same  => n,Hangup()

exten => _8XXX,1,NoOp(Appel entrant de l’Agence vers ${EXTEN})
 same  => n,Dial(SIP/${EXTEN},15)
 same  => n,Playback(vm-nobodyavail)
 same  => n,VoiceMail(${EXTEN}@main)
 same  => n,Hangup()
```

---

### 2.2 IPBX Agence (Bordeaux)

#### 2.2.1 `/etc/asterisk/sip.conf`
```ini
;--------------------------------------------------
; TRUNK SIP vers le PBX ENTREPRISE
;--------------------------------------------------
[entreprise-trunk]
type=peer
host=192.168.125.130         ; IP fixe du serveur Entreprise
context=from-entreprise      ; où arrivent SES appels
disallow=all
allow=ulaw
allow=alaw
directmedia=yes              ; RTP direct : pas de NAT
insecure=port,invite         ; pas d’auth (labo)
qualify=yes                  ; ping SIP toutes les 60 s
```

#### 2.2.2 `/etc/asterisk/extensions.conf`
```ini
include => outgoing-entreprise

;---------------------------------------------------------------------
;  SORTANT : tout numéro 7xxx / 8xxx part vers le trunk
;---------------------------------------------------------------------
[outgoing-entreprise]
exten => _7XXX,1,NoOp(Envoi ${EXTEN} vers Entreprise via trunk)
 same  => n,Dial(SIP/${EXTEN}@entreprise-trunk)
 same  => n,Hangup()

exten => _8XXX,1,NoOp(Envoi ${EXTEN} vers Entreprise via trunk)
 same  => n,Dial(SIP/${EXTEN}@entreprise-trunk)
 same  => n,Hangup()

;---------------------------------------------------------------------
;  ENTRANT : appels venant d’Entreprise
;---------------------------------------------------------------------
[from-entreprise]
; L’Entreprise nous envoie des 7xxx ou 8xxx
exten => _7XX,1,NoOp(Appel entrant de l’Entreprise vers ${EXTEN})
 same  => n,Dial(SIP/${EXTEN},15)
 same  => n,Playback(vm-nobodyavail)
 same  => n,VoiceMail(${EXTEN}@main)
 same  => n,Hangup()

exten => _8XX,1,NoOp(Appel entrant de l’Entreprise vers ${EXTEN})
 same  => n,Dial(SIP/${EXTEN},15)
 same  => n,Playback(vm-nobodyavail)
 same  => n,VoiceMail(${EXTEN}@main)
 same  => n,Hangup()
```

---

### 2.3 Note IPsec – Phase 2 dédiée au VLAN Voix **(INSERER PHOTO)**

Le tunnel IPsec existant transporte déjà le trafic « Data ». Pour garantir le **marquage QoS** et éviter tout NAT sur la VoIP, ajoutez une **seconde Phase 2** sur chaque pare‑feu :

| Site | Réseau local | Réseau distant | Usage |
|------|--------------|----------------|-------|
| Entreprise | **192.168.125.0/24** (VLAN Voix) | **10.0.128.0/24** (Voix Agence) | VoIP ↔ SIP/RTP |
| Agence | 10.0.128.0/24 | 192.168.125.0/24 | Symétrique |


---

## 3. Conclusion

Le trunk SIP entre l’Entreprise et l’Agence est maintenant opérationnel ; il s’appuie sur le tunnel IPsec existant pour assurer un trafic confidentiel et sans surcoût. Les collaborateurs composent simplement les numéros internes (7xx / 8xx) pour joindre leurs homologues, tandis que l’infrastructure reste prête à accueillir de nouveaux sites ou services (visio, centres d’appels) sans modification majeure.

Cette mise en place s’intègre donc parfaitement à la stratégie de convergence IP de Sportludique tout en constituant un élément valorisable lors de l’évaluation E6.
