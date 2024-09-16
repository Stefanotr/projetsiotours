# Configuration du Switch de Distribution

## A. Configuration de base

1. **Connexion et accès à la configuration:**
    - Connection au switch de distribution via son port console et minicom 
    - Authentifiez-vous avec les informations d'identification appropriées et accédez au mode de configuration privilégié.


3. **Configuration du VLAN 220 (admin):**
    ```plaintext
    vlan 220
    name admin
    interface vlan 220
    ip address 10.10.10.20 255.255.255.0
    no shutdown
    ```

4. **Configuration du port de liaison avec le switch coeur (trunk):**
    ```plaintext
    interface GigabitEthernet0/24
    switchport mode trunk
    ```

[Retour au sommaire](index.md)