# Configuration du LACP avec Cisco

Ce guide explique comment configurer un groupe d'agrégation de liens (LACP) sur un switch Cisco. Nous allons lier plusieurs interfaces physiques dans un **Port-channel** (groupe LAG) pour renforcer la disponibilité et la bande passante.

## Contexte

Dans ce scénario, nous avons plusieurs interfaces sur le switch qui se connectent à différentes VLANs, ainsi que deux interfaces dédiées à LACP. Ces interfaces forment un **Port-channel** (ou LAG), qui assure la connectivité entre notre cœur de réseau et le reste de l'infrastructure.

---

## Configuration de base du Port-channel

```bash
interface Port-channel1
 switchport mode trunk
```

Cette commande crée une **interface logique** appelée `Port-channel1`, qui agrège plusieurs interfaces physiques. Le mode **trunk** est activé pour transporter plusieurs VLANs à travers le lien.

---

## Configuration des interfaces physiques

Voici comment les interfaces physiques sont configurées pour appartenir à différents VLANs et participer à l'agrégation de liens :

```bash
interface GigabitEthernet1/0/18
 description "int LCAP"
 switchport mode trunk
 channel-group 1 mode active
```

```bash
interface GigabitEthernet1/0/19
 description "int LCAP"
 switchport mode trunk
 channel-group 1 mode active
```

Ces interfaces sont configurées avec le mode **trunk** pour permettre le passage de plusieurs VLANs et ajoutées au **Port-channel1** en utilisant la commande `channel-group`. Le mode `active` signifie que LACP est activé sur ces interfaces.

---

## Configuration VLAN des autres interfaces

Chaque interface est affectée à un VLAN spécifique. Voici quelques exemples :

```bash
interface GigabitEthernet1/0/1
 switchport access vlan 220
 switchport mode access
```

```bash
interface GigabitEthernet1/0/3
 switchport access vlan 221
 switchport mode access
 shutdown
```

* Les interfaces sont configurées en mode **access** pour faire partie d'un VLAN unique.
* L'interface `GigabitEthernet1/0/3` est désactivée avec la commande `shutdown` pour éviter tout trafic.

---

## Vérification de la configuration

Une fois la configuration terminée, vous pouvez utiliser la commande suivante pour vérifier l'état du Port-channel et des interfaces physiques qui y sont associées :

```bash
show running-config interface Port-channel1
```

Cela affichera la configuration actuelle de l'interface `Port-channel1`, y compris les interfaces physiques associées et leur état LACP.

---

## Explication

Le **LACP** (Link Aggregation Control Protocol) permet de regrouper plusieurs liens physiques pour former un lien logique, augmentant ainsi la bande passante disponible et assurant la redondance en cas de défaillance d'un lien. Dans cet exemple, les interfaces **GigabitEthernet1/0/18** et **GigabitEthernet1/0/19** sont agrégées dans un seul **Port-channel** pour garantir la continuité entre le cœur du réseau et le reste de l'infrastructure.

*Le LACP est particulièrement utile pour garantir une haute disponibilité dans les réseaux à grande échelle.*

---

## Conclusion

Cette configuration de LACP permet d'améliorer la **tolérance aux pannes** et d'augmenter la **bande passante** disponible en agrégant plusieurs interfaces physiques en un seul **Port-channel**.

---

<style>
code {
  background-color: #f4f4f4;
  color: #333;
  padding: 5px;
  border-radius: 5px;
}
pre {
  background-color: #272822;
  color: #f8f8f2;
  padding: 15px;
  border-radius: 10px;
}
h1, h2, h3 {
  color: #007BFF;
}
</style>