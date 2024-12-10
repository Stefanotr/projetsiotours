# 🛠️ Configurer et Tester un Pool ZFS dans Proxmox

## 📋 Objectif

Dans ce guide, nous allons configurer un pool **ZFS** dans Proxmox en utilisant un Logical Volume (LV) de **100 Go** provenant de notre **Volume Group (VGVMs)**. Nous intégrerons également le pool **VM-ZFS** dans Proxmox pour gérer le stockage.

---

## 📂 Étape 1 : Vérifions l'espace disponible dans le Volume Group

Avant de créer un Logical Volume pour ZFS, vérifions l'espace libre dans le VG **VGVMs** :

```bash
sudo vgs
```

### Exemple de sortie :
<pre>
VG     #PV #LV #SN Attr   VSize   VFree  
VGVMs    1  10   0 wz--n- 372.5g  120.0g
</pre>

- **VFree** montre l'espace disponible. Assurons-nous qu'il est supérieur à **100 Go** pour notre test.

---

## 🧱 Étape 2 : Créons un volume logique pour ZFS

Utilisons l'espace libre pour créer un volume logique de **100 Go** dans le Volume Group **VGVMs** :

```bash
sudo lvcreate -L 100G -n VM-ZFS VGVMs
```

### Vérifions la création :
```bash
sudo lvs
```

### Exemple de sortie :
<pre>
LV          VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
VM-ZFS      VGVMs  -wi-a----- 100.00g
</pre>

---

## 🌊 Étape 3 : Initialisons un pool ZFS

Transformons le volume logique en un nouveau pool ZFS nommé **VM-ZFS** :

```bash
sudo zpool create VM-ZFS /dev/VGVMs/VM-ZFS
```

### Vérifions la création du pool ZFS :
```bash
sudo zpool list
```

### Exemple de sortie :
<pre>
NAME       SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
VM-ZFS     100G   0B     100G       -        0%     0%  1.00x  ONLINE  -
</pre>

---

## 🛠️ Étape 4 : Ajoutons le pool ZFS dans Proxmox

Ajoutons le pool ZFS dans la configuration de Proxmox.

1. Ouvrons le fichier de configuration :
```bash
   sudo nano /etc/pve/storage.cfg
```

2. Ajoutons le bloc suivant pour le pool **VM-ZFS** :
```plaintext
   zfspool: VM-ZFS
       pool VM-ZFS
       content rootdir,images
       sparse
```

3. Redémarrons les services Proxmox pour appliquer les changements :
```bash
   sudo systemctl restart pvedaemon pveproxy
```

---

## 🖥️ Étape 5 : Vérifions dans l'interface web

1. Connectons-nous à l'interface web de Proxmox.
2. Allons dans **Datacenter → Storage**.
3. Vérifions que le stockage **VM-ZFS** est bien disponible.
4. Essayons de créer une VM ou un conteneur en utilisant ce stockage.

---

## 🔍 Étape 6 : Vérifions le Thin Provisioning

1. Affichons les propriétés du pool ZFS :
```bash
   zfs get all VM-ZFS
```

   Cherchons les lignes suivantes :
<pre>
   NAME       PROPERTY        VALUE      SOURCE
   VM-ZFS     reservation     none       default
</pre>

   - **`reservation=none`** indique que le thin provisioning est activé.

2. Si nous avons créé un volume pour une VM, affichons ses propriétés :
```bash
   zfs get volsize,refreservation,reservation VM-ZFS/vm-106-disk-0
```

   Exemple de sortie :
<pre>
   NAME                   PROPERTY        VALUE      SOURCE
   VM-ZFS/vm-106-disk-0   volsize         50G        local
   VM-ZFS/vm-106-disk-0   refreservation  none       local
   VM-ZFS/vm-106-disk-0   reservation     none       default
</pre>

   - **`refreservation=none`** confirme le thin provisioning.

---

## 🧹 Étape 7 : Nettoyons après le test (optionnel)

Si nous n'avons plus besoin du test, supprimons le pool ZFS et le volume logique.

1. Détruisons le pool ZFS :
```bash
   sudo zpool destroy VM-ZFS
```

2. Supprimons le volume logique :
```bash
   sudo lvremove /dev/VGVMs/VM-ZFS
```

---

## 📚 Conclusion

Nous avons configuré et testé **VM-ZFS** dans Proxmox en utilisant un espace dédié dans **VGVMs**. Cette configuration nous permet de bénéficier des fonctionnalités avancées de ZFS, telles que :

- Snapshots natifs.
- Clonage rapide.
- Thin provisioning.
- Compression intégrée.

Nous pouvons maintenant utiliser **VM-ZFS** comme pool de stockage principal dans Proxmox pour nos VM et conteneurs.
