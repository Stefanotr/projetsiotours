# 🛠️ Configurer un Volume Logique pour Stocker des ISO et Modèles de Conteneurs

## 📋 Objectif

Dans ce guide, nous allons expliquer comment nous avons configuré un Logical Volume **ISOC-LVM** de 50 Go pour stocker les fichiers ISO et les modèles de conteneurs dans Proxmox. Ce volume a été monté sur `/mnt/ISOC-LVM/` et organisé en deux répertoires : **Iso-Storage** et **Container-Templates**.

---

## 📂 Étape 1 : Création du Logical Volume ISOC-LVM

Nous avons commencé par créer un Logical Volume de 50 Go dans notre Volume Group **VGVMs**. Voici la commande utilisée :

```bash
sudo lvcreate -L 50G -n ISOC-LVM VGVMs
```

### Vérification de la création :
Après la création, nous avons vérifié la liste des Logical Volumes avec :

```bash
sudo lvs
```

### Exemple de sortie :
<pre>
LV          VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
ISOC-LVM    VGVMs  -wi-a-----  50.00g
</pre>

---

## 🌊 Étape 2 : Formatage et Montage du Volume

Nous avons formaté le volume avec un système de fichiers **ext4** pour y stocker nos fichiers.

### Formatage :
```bash
sudo mkfs.ext4 /dev/VGVMs/ISOC-LVM
```

### Création du point de montage :
Nous avons créé le répertoire de montage `/mnt/ISOC-LVM/` :

```bash
sudo mkdir -p /mnt/ISOC-LVM
```

### Montage du volume :
Ensuite, nous avons monté le Logical Volume à cet emplacement :

```bash
sudo mount /dev/VGVMs/ISOC-LVM /mnt/ISOC-LVM
```

### Rendre le montage permanent :
Pour que le montage soit automatique au redémarrage, nous avons ajouté une entrée dans `/etc/fstab` :

```bash
sudo nano /etc/fstab
```

Nous avons ajouté la ligne suivante à la fin du fichier :

```
/dev/VGVMs/ISOC-LVM  /mnt/ISOC-LVM  ext4  defaults  0  2
```

Nous avons ensuite testé la configuration avec :

```bash
sudo mount -a
```

---

## 🛠️ Étape 3 : Organisation des Répertoires

À partir de l’interface web Proxmox, nous avons créé deux répertoires directement dans `/mnt/ISOC-LVM/` pour organiser le stockage :

- **Iso-Storage** : pour stocker les fichiers ISO.
- **Container-Templates** : pour stocker les modèles de conteneurs.

### Structure finale :
Voici la structure du montage :

```
/mnt/ISOC-LVM/
├── Iso-Storage
└── Container-Templates
```

---

## 🖥️ Étape 4 : Configuration dans Proxmox

Nous avons ajouté ces deux répertoires comme stockages séparés dans Proxmox.

1. Dans l’interface web de Proxmox, nous sommes allés dans **Datacenter → Storage → Add → Directory**.
2. Nous avons ajouté **Iso-Storage** :
   - **ID** : Iso-Storage
   - **Directory** : `/mnt/ISOC-LVM/Iso-Storage`
   - **Content** : ISO image
3. Nous avons ajouté **Container-Templates** :
   - **ID** : Container-Templates
   - **Directory** : `/mnt/ISOC-LVM/Container-Templates`
   - **Content** : Container template

---

## 📂 Étape 5 : Vérification et Utilisation

### Vérification :
Nous avons vérifié que les deux stockages apparaissent dans l'interface web sous **Datacenter → Storage** et qu’ils acceptent les types de contenu appropriés (ISO et modèles de conteneurs).

### Test :
- Nous avons téléchargé un fichier ISO dans **Iso-Storage**.
- Nous avons ajouté un modèle de conteneur dans **Container-Templates**.

---

## 📚 Conclusion

Nous avons configuré **ISOC-LVM** pour stocker les ISO et modèles de conteneurs dans Proxmox. Cette configuration permet de séparer clairement les types de contenu et de maintenir une structure bien organisée. Nous pouvons maintenant utiliser ces répertoires pour gérer efficacement nos fichiers ISO et modèles dans Proxmox.