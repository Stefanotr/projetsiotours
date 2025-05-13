# Publication de la CRL et mise en place d'un serveur OCSP

## Constat initial

Au depart, la DSI de SportLudique a propose la mise en place d'une CRL (liste de certificats revoques) accessible via HTTP, hebergee sur le serveur `trustus`. L'objectif etait de permettre aux clients de verifier si un certificat avait ete revoque, sans connexion directe a l'autorite.

Cependant, lors des tests, nous avons constate que ce mecanisme etait **lourd, lent et peu adapte aux environnements modernes**. De plus, la plupart des navigateurs et clients SSL ne consultent pas toujours la CRL correctement ou de maniere systematique. Ce systeme etait donc considere comme **obsolete** dans le contexte actuel.

---

## Evolution vers OCSP

Apres analyse, la solution retenue a ete de passer a **OCSP (Online Certificate Status Protocol)**, qui permet une verification en ligne de l'etat d'un certificat, de maniere plus rapide et plus fiable.

Nous avons configure un serveur OCSP base sur OpenSSL, expose sur `http://trustus.mana.lan/ocsp` et `http://trustus.tours.sportludique.fr/ocsp`.

### Configuration OpenSSL avant OCSP

Voici un extrait de `openssl.cnf` avant la mise en place :

```ini
[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
```

---

## Mise en place d’OCSP et stapling

La configuration a ensuite ete amelioree pour inclure **les URLs OCSP et CRL** directement dans les extensions X.509 des certificats signes :

```ini
[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
crlDistributionPoints = @crl_urls
authorityInfoAccess = @ocsp_urls

[ v3_usr ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = critical, CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
crlDistributionPoints = @crl_urls
authorityInfoAccess = @ocsp_urls

[ crl_urls ]
URI.1 = http://trustus.tours.sportludique.fr/crl.pem
URI.2 = http://trustus.mana.lan/crl.pem

[ ocsp_urls ]
accessDescription.1 = OCSP;URI:http://trustus.mana.lan/ocsp
accessDescription.2 = OCSP;URI:http://trustus.tours.sportludique.fr/ocsp
```

> Le bloc `[ v3_usr ]` est utilise pour les certificats utilisateurs/serveurs.

---

## Adaptation necessaire des scripts

Malgre la presence des directives `authorityInfoAccess` et `crlDistributionPoints` dans le fichier `openssl.cnf`, **elles n’etaient pas toujours prises en compte lors de la signature** avec `openssl ca`.

Pour garantir que les URLs soient bien incluses dans les certificats, il a ete necessaire d’**ajouter manuellement les lignes correspondantes dans les fichiers d’extensions generes par les scripts (`extfile.cnf`)**, notamment :

```ini
crlDistributionPoints = URI:http://trustus.tours.sportludique.fr/crl.pem,URI:http://trustus.mana.lan/crl.pem
authorityInfoAccess = OCSP;URI:http://trustus.mana.lan/ocsp,OCSP;URI:http://trustus.tours.sportludique.fr/ocsp
```

Cela concerne notamment les scripts :

* `gen-fqdn.sh`
* `gen-wildcard.sh`
* `gen-chain.sh` (si extensions appliquees manuellement)

---

## Conclusion

La veritable securisation du systeme passe par l'utilisation :

* d'un **serveur OCSP local** pour verifier les certificats revoques en temps reel
* de l’**agrafage OCSP (OCSP stapling)**, qui permet au serveur web de fournir directement la reponse OCSP dans la connexion TLS

Grace a cette evolution, les clients obtiennent une preuve d’etats a jour, sans devoir contacter eux-memes le serveur OCSP.

➡️ Étape suivante : [Finalisation de la PKI : exploitation et distribution](05-finalisation-pki.md)
