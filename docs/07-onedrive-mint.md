# Installation de OneDrive sur Linux Mint

## Installation et Configuration de OneDrive

1. **Installation de OneDrive:**
    - Téléchargez et installez le paquet OneDrive en suivant le lien fourni : [Installation de OneDrive sur Linux Mint](https://community.linuxmint.com/software/view/onedrive).

    - Ouvrez un terminal et tapez la commande suivante pour lancer l'initialisation de OneDrive :
        ```bash
        onedrive
        ```

        Vous devriez voir un message comme celui-ci :
        ```plaintext
        Configuring Global Azure AD Endpoints
        Authorize this app visiting:
        https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=zlaa777-c83f-8a6b-a569-12c45698c&scope=Files.ReadWrite%20Files.ReadWrite.All%20Sites.ReadWrite.All%20offline_access&response_type=code&prompt=login&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient
        Enter the response uri:
        ```

2. **Connectez-vous à l'URL fournie dans un navigateur web.** Une fois connecté, copiez l'URL générée après la redirection et collez-la dans le terminal à l'invite "Enter the response uri:".

## Configuration du Dossier OneDrive

- Par défaut, le client OneDrive crée le dossier de synchronisation à `~/OneDrive`. Vous pouvez modifier ce chemin dans le fichier de configuration si nécessaire.

## Tester la Synchronisation

1. **Créez un fichier de test:**
    - Créez un petit fichier de test dans le dossier OneDrive pour vérifier la synchronisation.

2. **Synchronisez les fichiers manuellement:**
    ```bash
    onedrive --synchronize
    ```

3. **Vérifiez:**
    - Vérifiez sur votre compte OneDrive en ligne pour vous assurer que les fichiers ont été correctement synchronisés.

## Automatiser la Synchronisation au Démarrage

### Méthode 1 : Utiliser Systemd

1. **Créer un fichier de service Systemd:**
    - Ouvrez un terminal et créez le fichier de service avec `nano` :
        ```bash
        sudo nano /etc/systemd/system/onedrive.service
        ```

2. **Ajouter la configuration suivante:**
    ```plaintext
    [Unit]
    Description=OneDrive Free Client
    After=network-online.target
    Wants=network-online.target

    [Service]
    ExecStart=/usr/bin/onedrive --monitor
    Restart=always
    User=your_username
    Environment=DISPLAY=:0
    Environment=XAUTHORITY=/home/your_username/.Xauthority

    [Install]
    WantedBy=default.target
    ```

   Remplacez `your_username` par votre nom d'utilisateur réel.

3. **Sauvegarder et fermer le fichier:**
    - `CTRL + O` pour enregistrer, `CTRL + X` pour quitter.

4. **Recharger les fichiers de service Systemd:**
    ```bash
    sudo systemctl daemon-reload
    ```

5. **Activer le service pour qu'il démarre au démarrage:**
    ```bash
    sudo systemctl enable onedrive.service
    ```

6. **Démarrer immédiatement le service:**
    ```bash
    sudo systemctl start onedrive.service
    ```

### Méthode 2 : Ajouter OneDrive aux Applications de Démarrage

1. **Ouvrir les Applications de Démarrage:**
    - Accédez au menu "Menu" et recherchez "Applications de démarrage".

2. **Ajouter une nouvelle entrée:**
    - Cliquez sur "Ajouter".
    - **Nom** : OneDrive
    - **Commande** : `/usr/bin/onedrive --monitor`
    - **Commentaire** : Lance OneDrive en mode surveillance au démarrage.

3. **Sauvegarder la nouvelle entrée.**

[Retour au sommaire](index.md)