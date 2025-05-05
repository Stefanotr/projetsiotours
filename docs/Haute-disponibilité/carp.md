# Guide de configuration – Haute disponibilité CARP sur pfSense

## 1. Contexte : résilience des pare‑feux

Pour éviter tout point de défaillance unique, la plateforme Sportludique s’appuie sur deux pare‑feux pfSense en **mode haute disponibilité**. Le protocole **CARP** (Common Address Redundancy Protocol) publie des adresses IP virtuelles communes aux deux nœuds ; l’instance « Master » traite le trafic, tandis que la seconde reste en « Backup » et prend immédiatement le relais en cas de panne.

---

## 2. Procédure de configuration

### 2.1 Interface dédiée à la synchronisation

1. Ouvrez **Interfaces › Assignments** et ajoutez l’interface physique réservée à la synchronisation.
2. Attribuez des adresses IP dans le même sous‑réseau :
   - Pare‑feu principal : `172.28.138.1/24`
   - Pare‑feu secondaire : `172.28.138.2/24`
3. Activez l’interface et sauvegardez.

**PHOTO 1 – Interface Assignment**

---

### 2.2 Synchronisation sur le pare‑feu principal

1. Rendez‑vous dans **System › High Availability Sync**.
2. Cochez **Enable State Synchronization** et sélectionnez l’interface dédiée.
3. Renseignez l’adresse IP du secondaire (`172.28.138.2`).
4. Activez la synchronisation **XMLRPC**, puis indiquez :
   - IP du secondaire : `172.28.138.2`
   - Identifiants administrateur.
5. Sélectionnez tous les objets à synchroniser et cliquez sur **Save**.

**PHOTO 2 – High Availability Sync (Primary)**

---

### 2.3 Règles firewall sur l’interface CARP

Dans **Firewall › Rules** (onglet de l’interface dédiée) :

| Action | Proto | Source          | Destination       | Port | Objet |
|--------|-------|-----------------|-------------------|------|-------|
| Pass   | PFSYNC | CARP net        | CARP address      | —    | Synchronisation d’état |
| Pass   | TCP   | CARP address    | CARP net          | 443  | XMLRPC |

Appliquez et sauvegardez.

**PHOTO 3 – Rules on CARP Interface**

---

### 2.4 Création des adresses virtuelles (VIP)

1. Accédez à **Firewall › Virtual IPs** et cliquez sur **Add**.
2. Paramétrez :
   - **Type** : CARP
   - **Interface** : WAN (ou LAN)
   - **Virtual IP** : adresse partagée (ex. `x.x.x.x/24`)
   - **VHID** et **Password** sécurisés
3. Répétez pour chaque interface (WAN, LAN, DMZ…).

**PHOTO 4 – Virtual IPs list**

---

### 2.5 Configuration minimale sur le secondaire

Dans **System › High Availability Sync**, cochez uniquement **Enable State Synchronization**, sélectionnez l’interface CARP et renseignez l’IP du primaire (`172.28.138.1`). **Ne configurez pas** XMLRPC ici ; il sera géré par le primaire.

**PHOTO 5 – High Availability Sync (Secondary)**

---

### 2.6 Validation et tests

1. Mettez à jour les passerelles sur vos hôtes/routeurs pour pointer vers les VIP.
2. Simulez une panne du pare‑feu primaire et observez le basculement instantané (Status › CARP).

**PHOTO 6 – Status CARP**

---

## 3. Notes importantes

- Les configurations des deux nœuds doivent rester **strictement identiques** (packages, règles, certificates, etc.). XMLRPC s’en charge ; vérifiez les journaux après chaque modification.
- Utilisez toujours une interface physique **dédiée** pour CARP afin d’isoler le trafic de synchronisation.
- Pensez à autoriser le protocole **PFSYNC** et le port **443** (XMLRPC) sur l’interface CARP uniquement.

---

## 4. Conclusion

Votre cluster pfSense bénéficie désormais d’une **haute disponibilité** : les VIP maintiennent la connectivité côté clients, la synchronisation PFSYNC préserve les états des connexions, et XMLRPC réplique la configuration. Vérifiez régulièrement le statut CARP pour anticiper tout désalignement entre les nœuds.
