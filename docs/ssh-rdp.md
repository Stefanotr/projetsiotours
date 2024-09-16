# Accès à Distance (SSH et RDP)

## A. Configuration SSH sur le Serveur Debian

1. **Installation du serveur SSH (si nécessaire):**
    ```bash
    sudo apt update
    sudo apt install openssh-server
    ```

2. **Configuration du serveur SSH:**
    - Modifiez le fichier de configuration SSH `/etc/ssh/sshd_config` si nécessaire (par exemple, pour modifier le port par défaut).

3. **Redémarrez le service SSH:**
    ```bash
    sudo systemctl restart ssh
    ```

## B. Accès RDP au Serveur Windows 10

1. **Activer l'accès à distance:**
    - Ouvrez les "Paramètres Système" sur le serveur Windows 10.
    - Allez dans "Système" -> "Bureau à distance".
    - Activez l'option "Activer le Bureau à distance".

2. **Configurer l'accès RDP:**
    - Configurez les paramètres d'accès à distance, tels que les utilisateurs autorisés. ici admin

## C. Connexion aux Serveurs

1. **Connexion SSH au serveur Debian:**
    - Depuis un ordinateur Linux ou macOS:
        ```bash
        ssh utilisateur@10.10.10.16
        ```
    - Depuis un ordinateur Windows, utilisez un client SSH comme PuTTY.

2. **Connexion RDP au serveur Windows 10:**
    - Utilisez le client Bureau à distance intégré à Windows ou un client RDP tiers (ici freerdp)
    - 

[Retour au sommaire](index.md)