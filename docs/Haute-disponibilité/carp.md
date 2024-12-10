# Configuration de la Haute Disponibilité (CARP) avec PFsense

Ce guide explique comment configurer une paire de pare-feux PFsense en haute disponibilité (CARP).

---

## Prérequis
- Deux PFsense configurés (un principal et un secondaire).
- Adressage réseau défini pour chaque VLAN.
- Une interface Ethernet dédiée pour la synchronisation entre les deux PFsense.

---

## Étapes de Configuration

### 1. Configuration de l'Interface dédiée
1. Créez une nouvelle interface Ethernet dédiée sur **chaque PFsense**.
2. Assignez une IP dans le même réseau sur les deux pare-feux. Par exemple :
   - PFsense Principal : `172.28.138.1`
   - PFsense Secondaire : `172.28.138.2`
3. Activez l'interface et sauvegardez.

---

### 2. Configuration de la Synchronisation sur le Pare-feu Principal
1. Accédez à `System > High Availability Sync`.
2. Cochez **Enable State Synchronization**.
3. - Définissez :
    - Interface : Interface CARP.
    - Adresse du PFsense secondaire : `172.28.138.2`.
4. - Activez la synchronisation XMLRPC :
    - Renseignez l’adresse IP du PFsense secondaire.
    - Identifiant : `admin`.
    - Mot de passe : Utilisez le mot de passe administrateur.
5. Cochez toutes les options de synchronisation et sauvegardez.

---

### 3. Configuration des Règles Firewall
1. Accédez à `Firewall > Rules` dans l'interface dédiée (CARP).
2. Créez les règles suivantes :
   - **Règle 1** :
     - Action : PASS
     - Protocole : PFSYNC
     - Source : CARP1 net
     - Destination : CARP1 address
   - **Règle 2** :
     - Action : PASS
     - Protocole : TCP/UDP
     - Source : CARP1 address
     - Destination : CARP1 net
     - Ports : 443 (ou autres ports nécessaires).
3. Sauvegardez les règles.

---

### 4. Création des VIP (Virtual IPs)
1. Accédez à `Firewall > Virtual IPs`.
2. Cliquez sur **Add** pour ajouter une nouvelle VIP.
3. Configurez les paramètres :
   - Type : CARP
   - Interface : Sélectionnez l’interface (WAN ou LAN).
   - Adresse IP : Assignez une nouvelle IP partagée entre les deux PFsense.
   - Mot de passe : Configurez un mot de passe sécurisé.
4. Répétez l’opération pour chaque interface (par exemple, LAN et WAN).

---

### 5. Configuration sur le Pare-feu Secondaire
1. Accédez à `System > High Availability Sync`.
2. Cochez **Enable State Synchronization**.
3. Configurez les paramètres :
   - Interface : Interface dédiée (CARP).
   - Adresse CARP du PFsense principal : `172.28.138.1`.
4. **Note :** Ne configurez pas la synchronisation XMLRPC. Celle-ci est automatique.

---

### 6. Règles Firewall sur le Secondaire
1. Accédez à `Firewall > Rules` dans l'interface CARP.
2. Créez une règle **PASS ALL** pour permettre tout trafic.

---

### 7. Finalisation
- Mettez à jour les adresses IP des routes et des passerelles pour utiliser les VIP créées.
- Testez la bascule entre les deux PFsense pour vérifier la haute disponibilité.

---

## Notes Importantes
- La synchronisation entre les pare-feux s’effectue automatiquement pour les configurations XMLRPC.
- Vérifiez que les deux PFsense ont des configurations réseau cohérentes avant d'activer CARP.

---

## Résultat
Votre infrastructure PFsense est maintenant configurée en haute disponibilité avec CARP. 🎉
