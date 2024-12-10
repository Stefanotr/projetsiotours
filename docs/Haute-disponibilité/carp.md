# 🔄 Configuration de la Haute Disponibilité (CARP) avec PFsense

Ce guide explique comment configurer une paire de pare-feux PFsense en haute disponibilité grâce au protocole CARP.

---

## 🛠️ Prérequis
- ⚙️ Deux PFsense configurés (un principal et un secondaire).
- 🧾 Adressage réseau défini pour chaque VLAN.
- 📡 Une interface Ethernet dédiée à la synchronisation entre les deux PFsense.

---

## 🚀 Étapes de Configuration

### 1️⃣ Configuration de l'Interface dédiée
1. Accédez à **Interfaces > Assign** pour ajouter une nouvelle interface Ethernet dédiée sur **chaque PFsense**.
2. Configurez les adresses IP sur le même réseau pour les deux pare-feux. Par exemple :
   - PFsense Principal : `172.28.138.1`
   - PFsense Secondaire : `172.28.138.2`
3. Activez les interfaces et sauvegardez.

```bash
# Exemple de configuration CLI
ifconfig em3 172.28.138.1 netmask 255.255.255.0 up
```

---

### 2️⃣ Configuration de la Synchronisation sur le Pare-feu Principal
1. Rendez-vous dans **System > High Availability Sync**.
2. Cochez **Enable State Synchronization**.
3. Configurez les paramètres suivants :
   - **Interface** : Interface dédiée (CARP).
   - **Adresse du PFsense secondaire** : `172.28.138.2`.
4. Activez la synchronisation XMLRPC :
   - Adresse IP : `172.28.138.2`
   - Identifiant : `admin`
   - Mot de passe : Celui de l’utilisateur administrateur.
5. Sélectionnez toutes les options de synchronisation et cliquez sur **Save**.

---

### 3️⃣ Configuration des Règles Firewall
1. Accédez à **Firewall > Rules** sur l'interface dédiée (CARP).
2. Ajoutez les règles suivantes :

   - **Règle 1 : Synchronisation d'état**
     - Action : PASS
     - Protocole : PFSYNC
     - Source : `CARP1 net`
     - Destination : `CARP1 address`
   - **Règle 2 : Autorisation XMLRPC**
     - Action : PASS
     - Protocole : TCP
     - Source : `CARP1 address`
     - Destination : `CARP1 net`
     - Port : 443

```bash
# Exemple d'autorisation sur l'interface CARP
pfctl -a "carp" -sr
```

---

### 4️⃣ Création des VIP (Virtual IPs)
1. Accédez à **Firewall > Virtual IPs**.
2. Cliquez sur **Add** pour ajouter une nouvelle VIP.
3. Configurez comme suit :
   - **Type** : CARP
   - **Interface** : WAN ou LAN.
   - **Adresse IP** : Nouvelle IP partagée entre les deux PFsense.
   - **Mot de passe** : Configurez un mot de passe sécurisé.
4. Répétez l’opération pour chaque interface (WAN, LAN, etc.).

---

### 5️⃣ Configuration sur le Pare-feu Secondaire
1. Accédez à **System > High Availability Sync**.
2. Cochez **Enable State Synchronization**.
3. Configurez les paramètres suivants :
   - **Interface** : Interface dédiée (CARP).
   - **Adresse du PFsense principal** : `172.28.138.1`.

⚠️ **Note** : Ne configurez pas la synchronisation XMLRPC sur le secondaire, elle sera gérée par le primaire.

---

### 6️⃣ Finalisation et Test
1. Mettez à jour les adresses des routes et passerelles pour pointer vers les VIP.
2. Testez la bascule en simulant un arrêt du PFsense principal pour valider la haute disponibilité.

---

## 📝 Notes Importantes
- La synchronisation s’effectue automatiquement pour les configurations XMLRPC.
- Les deux PFsense doivent avoir des configurations réseau identiques pour éviter les incohérences.
- Utilisez une interface dédiée pour CARP afin d’éviter tout conflit.

---

## 🎉 Résultat
Votre infrastructure est maintenant configurée en haute disponibilité avec PFsense et CARP. Testez la bascule pour garantir un fonctionnement optimal !