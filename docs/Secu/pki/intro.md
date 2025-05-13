# Infrastructure PKI de SportLudique

## Introduction

Dans le cadre de la sécurisation des accès HTTPS aux serveurs internes et aux interfaces web d’administration des équipements réseau, **la DSI de SportLudique** a décidé de **remplacer l'ancienne autorité de certification interne (ACG-SL)** par une nouvelle autorité plus robuste nommée **STS Root R2**.

Cette migration vise à répondre à des exigences de sécurité plus strictes, notamment :

- Utilisation de **certificats à courbe elliptique (ECC)** pour des clés plus légères et plus sûres.
- Standard **prime256v1** choisi comme base cryptographique.
- Intégration complète du protocole **OCSP** pour une vérification instantanée de la validité des certificats.
- Meilleure gestion des révocations via **CRL** et OCSP.
- Automatisation complète de la génération, la signature, la révocation et le renouvellement des certificats via **des scripts personnalisés**.

---

## Objectifs

| Objectif                        | Description                                                                 |
|--------------------------------|-----------------------------------------------------------------------------|
| 🔐 Renforcer la sécurité        | Certificats ECC, meilleure entropie, vérification OCSP                     |
| 🔁 Révocation rapide            | Support CRL + OCSP, publication automatique sur le serveur Trustus         |
| ⚙️ Automatisation               | Génération et gestion via scripts shell (`gen-fqdn.sh`, `revoke-cert.sh`) |
| 🛡️ Centralisation               | Tous les certificats signés par **STS Root R2**, autorité locale unique    |
| 🌐 Intégration serveur web     | Intégration dans **NGINX**, **OCSP Stapling**, publication HTTPS           |

---

## Composants de l'infrastructure

| Composant            | Rôle                                                                 |
|----------------------|----------------------------------------------------------------------|
| `STS Root R2`        | Autorité de certification principale auto-signée                     |
| `CRL`                | Liste de certificats révoqués, publiée en HTTP                       |
| `OCSP`               | Service en ligne répondant en temps réel sur le statut des certificats |
| `NGINX`              | Serveur HTTP+OCSP Stapling pour publication                          |
| `Scripts`            | Automatisation de la génération, révocation, renouvellement          |

---

## Courbe elliptique : `prime256v1`

Le choix de `prime256v1` (aussi appelée **secp256r1**) repose sur :

- Une **clé de 256 bits** offrant un bon compromis entre sécurité et performance.
- Une adoption large dans les navigateurs et serveurs modernes.
- Une meilleure efficacité par rapport aux clés RSA de 2048 bits.

---

## Schéma logique de la PKI

```text
                ┌─────────────────────┐
                │     STS Root R2     │
                │ (Autorité Racine)   │
                └────────┬────────────┘
                         │
                ┌────────▼────────┐
                │ Certificats ECC │◄────────────┐
                │  FQDN / Wildcard│             │
                └──────┬──────────┘             │
                       │                        │
        ┌──────────────▼──────────────┐         │
        │ Publication CRL + OCSP      │         │
        │ sur serveur HTTP "trustus"  │         │
        └─────────────────────────────┘         │
                                               ▼
                                  ┌───────────────────────────┐
                                  │    Clients / navigateurs   │
                                  │    vérifient via OCSP      │
                                  └───────────────────────────┘
````

---

## Automatisation

Tous les processus critiques de la PKI sont **entièrement automatisés** :

| Script                | Fonction                                        |
| --------------------- | ----------------------------------------------- |
| `csr-et-signe-sts.sh` | Menu interactif pour signer FQDN, wildcard, etc |
| `gen-fqdn.sh`         | Génération d’un certificat avec SAN             |
| `gen-wildcard.sh`     | Génération d’un certificat \*.domaine.tld       |
| `gen-chain.sh`        | Signature d’une autorité intermédiaire          |
| `revoke-cert.sh`      | Révocation d’un certificat + mise à jour CRL    |
| `renew-cert.sh`       | Renouvellement d’un certificat existant         |

---

## Conclusion

L’infrastructure STS Root R2 permet à SportLudique de disposer d’une **PKI moderne, performante et totalement autonome**, capable d’émettre, suivre et révoquer des certificats de manière sécurisée.

> Tous les certificats doivent être signés par STS Root R2 et **installés manuellement** sur les postes clients pour garantir la reconnaissance des services HTTPS internes.
