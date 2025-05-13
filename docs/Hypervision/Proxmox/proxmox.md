# 🚀 Installer Proxmox VE

## 📋 Objectif

Ce tutoriel décrit toutes les étapes nécessaires pour installer **Proxmox VE** sur un serveur Debian, avec les optimisations post-installation pour un environnement fonctionnel et sécurisé.

---

## 🛠️ Étape 1 : Adapter le fichier `sources.list`

Ajoutez le dépôt Proxmox VE avec la commande suivante :

```bash
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
```

Téléchargez et ajoutez la clé de ce dépôt :

```bash
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
```

Vérifiez son intégrité :

```bash
sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
# Résultat attendu :
# 7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87
```

---

## 🔄 Étape 2 : Mise à jour des dépôts et du système

Mettez à jour les paquets et appliquez les mises à jour système avec :

```bash
apt update && apt full-upgrade
```

---

## 🧩 Étape 3 : Installer le noyau Proxmox VE

Installez et redémarrez sur le noyau Proxmox VE :

```bash
apt install proxmox-default-kernel
systemctl reboot
```

---

## 📦 Étape 4 : Installer les paquets Proxmox VE

Installez les composants essentiels pour Proxmox VE :

```bash
apt install proxmox-ve postfix open-iscsi chrony
```

> Pendant l'installation, configurez `postfix` selon vos besoins. Choisissez "local only" si vous ne gérez pas de serveur mail.

---

## ❌ Étape 5 : Supprimer le noyau Debian

Pour éviter les conflits de versions, supprimez le noyau par défaut de Debian :

```bash
apt remove linux-image-amd64 'linux-image-6.1*'
```

Mettez à jour et vérifiez la configuration de `grub2` :

```bash
update-grub
```

---

## 🧹 Étape 6 : Optionnel - Supprimer `os-prober`

Supprimez `os-prober` si vous n'utilisez pas de dual boot, pour éviter des entrées de démarrage incorrectes :

```bash
apt remove os-prober
```

---

## 🌐 Étape 7 : Connectez-vous à l'interface web

Accédez à l'interface web de Proxmox VE :  
[https://votre-ip:8006](https://votre-ip:8006)

- **Identifiant** : `root`
- **Authentification** : **PAM**

---

## ⚙️ Étape 8 : Script de post-installation

Pour simplifier la configuration, exécutez le script de post-installation recommandé :

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
```

Ensuite, supprimez le dépôt "no-subscription" :

```bash
rm /etc/apt/sources.list.d/pve-install-repo.list
```

---

## 📚 Conclusion

Vous avez installé et configuré **Proxmox VE** avec succès. Explorez les fonctionnalités via l'interface web pour gérer vos machines virtuelles et conteneurs efficacement. 🎉