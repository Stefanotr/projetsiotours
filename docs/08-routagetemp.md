# Configuration du routage temporaire

## Problématique

Pour l'installation de Debian, un accès à Internet est indispensable. Cependant, notre infrastructure actuelle ne dispose d'aucun VLAN offrant une connexion Internet directe. Une solution envisageable serait de router la connexion Wi-Fi du lycée vers notre réseau local (LAN) afin de permettre l'accès à Internet nécessaire pour l'installation.

## Configuration du Routage et du NAT

Sur mon PC local, j'ai activé le routage IP avec la commande suivante :

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Ensuite, j'ai configuré le NAT pour permettre le partage de la connexion Internet via l'interface Wi-Fi (wlo1) avec la commande :

```bash
sudo iptables -t nat -A POSTROUTING -o wlo1 -j MASQUERADE
```

Ainsi, mon PC fonctionne désormais comme un routeur, permettant aux autres appareils de se connecter à Internet à travers la connexion Wi-Fi de mon PC.

De plus, il est crucial de modifier la configuration IP des machines hôtes en spécifiant un DNS valide et en configurant la passerelle (l'IP de mon PC). Ainsi, mon PC fonctionne désormais comme un routeur, permettant aux autres appareils de se connecter à Internet à travers la connexion Wi-Fi de mon PC.

## Configuration Réseau sur Debian

Pour configurer l'adresse IP, le sous-réseau, le serveur DNS et la passerelle sur une machine Debian, suivez les étapes ci-dessous.

### 1. Modifier la Configuration de l'Adresse IP

Les configurations réseau sont généralement gérées via le fichier `/etc/network/interfaces` sur les systèmes Debian. Vous pouvez modifier ce fichier pour définir une adresse IP statique.

1. Ouvrez le fichier de configuration avec un éditeur de texte :

    ```bash
    sudo nano /etc/network/interfaces
    ```

2. Ajoutez ou modifiez la configuration de votre interface réseau. Remplacez `eth0` par le nom de votre interface réseau, et ajustez les valeurs pour l'adresse IP, le masque de sous-réseau, et la passerelle :

    ```plaintext
    auto eth0
    iface eth0 inet static
        address 10.10.10.16
        netmask 255.255.255.0
        gateway 10.10.10.40
    ```

3. Enregistrez et fermez le fichier.

### 2. Configurer les Serveurs DNS

Pour configurer les serveurs DNS, modifiez le fichier `/etc/resolv.conf`.

1. Ouvrez le fichier avec un éditeur de texte :

    ```bash
    sudo nano /etc/resolv.conf
    ```

2. Ajoutez les adresses des serveurs DNS. Par exemple :

    ```plaintext
    nameserver 172.16.10.1
    nameserver 172.16.10.10
    ```

3. Enregistrez et fermez le fichier.

### 3. Redémarrer le Service Réseau

Après avoir modifié les fichiers de configuration, redémarrez le service réseau pour appliquer les changements :

```bash
sudo systemctl restart networking
```

### 4. Vérifier la Configuration

Vous pouvez vérifier votre configuration réseau avec les commandes suivantes :

- Pour afficher les informations sur les interfaces réseau :

    ```
    ip addr show
    ```

- Pour vérifier la connectivité avec la passerelle :

    ```
    ping -c 4 10.10.10.40
    ```

- Pour vérifier les serveurs DNS :

    ```
    cat /etc/resolv.conf
    ```
