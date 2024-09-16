# Configuration du Switch Coeur

## A. Configuration de base

1. **Connexion et accès à la configuration:**
    - Connection au switch coeur via son port console et minicom
    - config du switch (mot de passe, SSH, vlan interface) 

2. 
  [Configuration de base des switch](03-swbase.md)

3. **Configuration du VLAN d'administration (VLAN 220):**
    ```plaintext
    vlan 220
    name admin
    interface vlan 220
    ip address 10.10.10.10 255.255.255.0
    no shutdown
    ```

4. **Configuration du port de liaison avec le switch de distribution (trunk):**
    ```plaintext
    interface GigabitEthernet1/0/1  (Remplacez par le port physique correspondant)
    switchport mode trunk
    ```

[Retour au sommaire](index.md)