# Automatisation de la génération et de la signature des certificats

Dans un objectif de standardisation et de sécurité, la DSI de SportLudique a mis en place un système automatisé pour la gestion des certificats SSL. Cette solution repose sur un script principal interactif accompagné de scripts dédiés à différents types de certificats.

Tous les fichiers sensibles de l’autorité de certification (CA) sont strictement localisés dans :

```
/etc/ssl/STS-Root-R2
```

---

## Objectifs

* Automatiser la génération des clés privées et des demandes de certificats (CSR)
* Signer automatiquement les certificats avec la CA STS Root R2
* Isoler les fichiers utilisateurs dans un répertoire sécurisé dédié

---

## Structure du projet

```text
~/STS-Root-R2/
├── csr-et-signe-sts.sh       ← Script principal (menu interactif)
└── Scripts/
    ├── gen-fqdn.sh           ← Certificats FQDN
    ├── gen-wildcard.sh       ← Certificats wildcard
    └── gen-chain.sh          ← Autorités intermédiaires
```

---

## Script principal : `csr-et-signe-sts.sh`

Ce script interactif affiche le menu suivant :

```none
STS Root R2 – Menu de génération de certificats
-----------------------------------------------
1. Générer un certificat FQDN
2. Générer un certificat Wildcard
3. Générer un certificat d'autorité intermédiaire
0. Quitter
```

Chaque option appelle un script spécifique détaillé ci-dessous.

---

## Détail des scripts

### `gen-fqdn.sh` – Certificat FQDN

Ce script permet de générer un certificat standard pour un nom de domaine complet (FQDN).

**Fonctionnalités** :

* Génération d’une clé ECC (`prime256v1`)
* Saisie interactive des informations du CSR
* Ajout optionnel de SAN
* Signature automatique via `openssl ca`
* Fichiers générés dans :

```text
~/STS-Root-R2/Client/<domaine>/
```

Lien vers le script : [Scripts/gen-fqdn.sh](./Scripts/gen-fqdn.sh)

---

### `gen-wildcard.sh` – Certificat Wildcard

Ce script permet de générer un certificat de type wildcard pour un domaine donné.

**Fonctionnalités** :

* CN = `*.<domaine>`
* SAN = `DNS:<domaine>, DNS:*.<domaine>`
* Clé ECC `prime256v1`
* Signature automatique via `openssl ca`
* Fichiers générés dans :

```text
~/STS-Root-R2/Client/wildcard_<domaine>/
```

Lien vers le script : [Scripts/gen-wildcard.sh](./Scripts/gen-wildcard.sh)

---

### `gen-chain.sh` – Autorité intermédiaire

Ce script permet de générer une autorité intermédiaire signée par STS Root R2.

**Fonctionnalités** :

* Génération d’une nouvelle autorité avec le profil `v3_ca`
* CN = FQDN de l’autorité intermédiaire
* Fichiers générés dans :

```text
~/STS-Root-R2/Client/intermediate_<domaine>/
```

Lien vers le script : [Scripts/gen-chain.sh](./Scripts/gen-chain.sh)

---

## Bonnes pratiques

* Ne jamais modifier directement les fichiers de la CA principale.
* Tous les fichiers critiques sont stockés dans :

```text
/etc/ssl/STS-Root-R2/
```

* Tous les certificats (serveurs, utilisateurs, wildcard, chaînes) doivent être créés via les scripts du répertoire :

```text
~/STS-Root-R2/Scripts/
```

Aucun script ne modifie les fichiers internes de la CA, sauf lors de la signature via `openssl ca`.

---

## Étape suivante

Consulter : [04 – Publication de la CRL & Mise en place d’un serveur OCSP](04-crl-et-ocsp.md)