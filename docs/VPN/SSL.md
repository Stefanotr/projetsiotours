 Guide de configuration – VPN SSL (OpenVPN) sur Stormshield SNS

## 1. Contexte : accès nomade sécurisé pour Sportludique

Les collaborateurs **nomades** (télétravail, déplacement, wifi publics) doivent accéder aux ressources internes (ERP, partage de fichiers, intranet) via une connexion chiffrée. Le pare‑feu **Stormshield SNS** intègre un service **VPN SSL complet** (moteur **OpenVPN**), idéal car :

- Fonctionne sur **TCP 443** ou **UDP 1194** → passe les filtrages stricts ;
- Authentification forte : certificats X.509 + annuaire LDAP/AD ;
- Distribution **automatique** du client et de la configuration via le **portail captif** ;
- Intégration complète aux règles de filtrage, proxies et QoS du pare‑feu.

---

## 2. Procédure de configuration

> Version SNS 4.x ; capture d’écran à ajouter → **PHOTO X**.

### 2.1 Pré‑requis

1. **Annuaire** relié à l'active directory activé ;
2. **Méthode d’authentification explicite** (LDAP/AD, RADIUS, Kerberos) activée ;
3. **Profil portail captif** associé à l’interface externe.

**PHOTO 1 – Méthode d’authentification + portail**

### 2.2 Activation du serveur VPN SSL

1. **Configuration › VPN › VPN SSL** → cocher **Activer le VPN SSL**.
2. Renseigner :
   - **Adresse publique** ou FQDN du pare‑feu ;
   - **Réseaux accessibles** (objets internes) ;
   - **DNS suffix** + serveurs DNS internes ;
   - **Plages d’adresses** dédiées TCP & UDP (ex. 10.60.77.0/24 et 10.61.77.0/24).
3. Laisser l’algorithme de **renégociation** à 14 400 s (4 h) ou ajuster.

**PHOTO 2 – Paramètres réseau & certificats**

### 2.3 Certificats

- CA par défaut `sslvpn-full-default-authority` suffisante.
- Pour CA perso : importer **certificat serveur** + **certificat client** signés par la même CA.

### 2.4 Droits d’accès

1. **Configuration › Utilisateurs › Droits d’accès**.
2. Laisser l’accès global sur *Interdire* et créer une règle **Accès détaillé** ⇒ sélectionner le **groupe Nomades** → *Autoriser* VPN SSL.

**PHOTO 3 – Règle d’autorisation**

### 2.5 Politique de sécurité

| Sens | Objet source | Objet dest. | Service | Action |
|------|--------------|-------------|---------|--------|
| WAN → UTM | `Any` | *Interface Ext* | `1194/UDP`, `443/TCP` | **Allow** |
| VPN_clients → LAN | `VPN_SSL_Clients` | `LAN_Nets` | `Any` | **Allow / IPS On** |
| VPN_clients → Internet | `VPN_SSL_Clients` | `any` | `Any` | **NAT → WAN IP** |

> Activer la règle implicite « Accès au portail d’authentification et au VPN SSL » si non présent.

### 2.6 Client VPN (Windows)

1. Télécharger **Stormshield SSL VPN Client** depuis <https://Pare‑feu/auth> (**PHOTO 4**).
2. Lancer l’installation (droits administrateur requis).
3. Premier lancement : renseigner
   - **Serveur** : `vpn.tours.sportludique.fr` (ou IP) [+ `:port` si custom] ;
   - **Identifiant / mot de passe** LDAP.
4. Le client télécharge automatiquement `openvpn_client.zip` ( CA, cert , conf) et établit le tunnel.

Codes couleur : Rouge = déconnecté, Jaune = négociation, Vert = connecté.

### 2.7 Client OpenVPN (Linux)

Décompresser `openvpn_client.zip` :
```bash
o unzip openvpn_client.zip -d ~/vpn_ssl
sudo openvpn --config client.ovpn
```
Extrait de `client.ovpn` :
```bash
dev tun
remote vpn.tours.sportludique.fr 1194 udp
cipher AES-256-CBC
auth SHA256
ca CA.cert.pem
cert openvpnclient.cert.pem
key  openvpnclient.pkey.pem
compress lz4
auth-user-pass
auth-nocache
```
Pour Network‑Manager : **PHOTO 5 – onglet Identité / Avancé**.

### 2.8 Vérifications & supervision

- Pare‑feu : **Supervision › Tunnels VPN SSL** (**PHOTO 6**).
- Traces client Windows : clic droit → *Logs*.
- Route Linux : `ip route show dev tun0` : présence route par défaut 10.60.77.5.

---

## 3. Conclusion

Le VPN SSL complet offre :

- **Authentification** LDAP + certificats X.509 ;
- **Chiffrement TLS** sur ports 1194/UDP ou 443/TCP (bypass proxy) ;
- **Accès transparent** aux réseaux internes avec contrôle par les règles du pare‑feu ;
- **Distribution automatisée** de la configuration (ZIP) pour une expérience utilisateur simplifiée ;
- **Supervision centralisée** des tunnels et intégration aux logs Stormshield.

La solution garantit ainsi confidentialité, intégrité et continuité de service pour les utilisateurs nomades de Sportludique.
