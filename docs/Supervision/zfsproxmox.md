<style>
/* Styles pour les blocs <code> */
code {
  background-color: #1e1e2f; /* Couleur sombre moderne */
  color: #72c6ff;           /* Couleur bleue lumineuse pour le texte */
  padding: 8px;             /* Augmente l'espace pour un meilleur confort visuel */
  border-radius: 6px;       /* Coins légèrement arrondis */
  font-family: "Courier New", Courier, monospace; /* Police adaptée au code */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Ajout d'une ombre subtile */
  transition: background-color 0.3s, color 0.3s; /* Animation au survol */
}

code:hover {
  background-color: #2a2a3d; /* Changement de fond au survol */
  color: #ffffff;           /* Contraste blanc pour le texte */
}

/* Styles pour les blocs <pre> */
pre {
  background-color: #121212; /* Fond sombre profond */
  color: #e0e0e0;           /* Texte légèrement gris pour moins d'éblouissement */
  padding: 20px;            /* Plus d'espace interne */
  margin: 20px 0;           /* Marge améliorée */
  border-radius: 10px;      /* Coins arrondis pour un design moderne */
  font-family: "Courier New", Courier, monospace; /* Police adaptée */
  font-size: 15px;          /* Taille de police optimale */
  line-height: 1.6;         /* Meilleure lisibilité */
  overflow-x: auto;         /* Barre de défilement horizontale si nécessaire */
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.2); /* Ombre pour un effet "flottant" */
  transition: transform 0.3s, box-shadow 0.3s; /* Animation au survol */
}

pre:hover {
  transform: scale(1.02);   /* Légère mise en avant au survol */
  box-shadow: 0 12px 20px rgba(0, 0, 0, 0.3); /* Accentuation de l'ombre */
}

/* Styles pour les titres */
h1, h2, h3 {
  color: #72c6ff;           /* Couleur bleue lumineuse */
  font-family: "Roboto", sans-serif; /* Police moderne et lisible */
  font-weight: bold;        /* Titres plus marqués */
  text-transform: uppercase; /* Titres en majuscules pour un effet impactant */
  letter-spacing: 1px;      /* Espacement des lettres */
  margin-bottom: 10px;      /* Marge inférieure ajustée */
  transition: color 0.3s;   /* Animation pour changement de couleur */
}

h1:hover, h2:hover, h3:hover {
  color: #ffffff;           /* Changement de couleur au survol */
}

/* Ajout de styles interactifs pour les liens */
a {
  color: #72c6ff;
  text-decoration: none;
  border-bottom: 2px solid transparent;
  transition: color 0.3s, border-bottom-color 0.3s;
}

a:hover {
  color: #ffffff;
  border-bottom-color: #72c6ff;
}

/* Responsiveness */
@media (max-width: 768px) {
  pre, code {
    font-size: 14px; /* Taille réduite pour les écrans plus petits */
  }
}

</style>

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
