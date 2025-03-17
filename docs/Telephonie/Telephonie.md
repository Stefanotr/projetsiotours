# Documentation Complète sur l’Installation et la Configuration d’Asterisk et de Téléphones Cisco

Cette documentation fournit un guide étape par étape pour :

- Installer **Asterisk 18.x**.
- Préparer un **serveur TFTP** et un **DHCP** pour les téléphones.
- Déployer et configurer des **téléphones Cisco**.
- Configurer les fichiers principaux d’Asterisk (sip.conf, extensions.conf, voicemail.conf).

---

## 1. Installation d’Asterisk 18.x

### 1.1 Prérequis

Mettez à jour votre système et installez les paquets essentiels :

```bash
sudo apt update && sudo apt upgrade
sudo apt install wget build-essential subversion
```

Placez-vous ensuite dans le répertoire `/usr/src/` et téléchargez la source :

```bash
cd /usr/src/
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar zxf asterisk-18-current.tar.gz
cd asterisk-18.*/
```

### 1.2 Préparation des dépendances

Asterisk nécessite certains modules. Exécutez :

```bash
sudo contrib/scripts/get_mp3_source.sh
sudo contrib/scripts/install_prereq install
```

Lorsque vous y êtes invité, entrez `33` pour la **France** (indiquant la localisation).

Ensuite, lancez la configuration :

```bash
sudo ./configure
```

### 1.3 Compilation et installation

Choisissez les modules à compiler via le menu **menuselect** :

```bash
sudo make menuselect
```

- Dans `menuselect`, activez le module `format mp3`.

Compilez, installez et configurez Asterisk :

```bash
sudo make -j2
sudo make install
sudo make samples
sudo make config
sudo ldconfig
```

Activez et démarrez le service :

```bash
sudo systemctl start asterisk
sudo asterisk -vvvr
```

---

### 1.4 Création de l’utilisateur et groupe Asterisk

Pour des raisons de sécurité, on crée un utilisateur système dédié :

```bash
sudo adduser --system --group --no-create-home --disabled-login asterisk
sudo chown -R asterisk:asterisk /etc/asterisk /var/{lib,log,run,spool}/asterisk
sudo chmod -R 750 /etc/asterisk
```

Modifiez ensuite `/etc/asterisk/asterisk.conf` :

- Recherchez les lignes :
  ```
  runuser = asterisk
  rungroup = asterisk
  ```
- Retirez les éventuels `;` pour décommenter.

Redémarrez Asterisk :

```bash
sudo systemctl restart asterisk
```

Pour vérifier que le service tourne avec l’utilisateur *asterisk* :

```bash
ps aux | grep asterisk
```

---

## 2. Mise en place d’un serveur TFTP et DHCP

1. **Configurer un pool DHCP** dédié aux téléphones, et ajouter l’option 66 pointant vers votre serveur TFTP.
2. **Installer et configurer un serveur TFTP** (ex. `tftpd-hpa`) et placez-y les firmwares des téléphones Cisco.
3. Dans le répertoire `/srv/tftp/` (ou le répertoire choisi pour TFTP), décompressez le firmware du téléphone.
4. Lorsque le téléphone redémarre et reçoit une IP via DHCP, il ira chercher automatiquement son firmware.

---

## 3. Configuration SIP pour les Téléphones Cisco

Après réinitialisation d’usine, la configuration SIP des téléphones Cisco se fait via **trois fichiers XML** placés à la racine de votre serveur TFTP :

1. **XMLDefault.cnf.xml**
2. **dialplan.xml** (ou plusieurs fichiers dialplan, un par téléphone si nécessaire)
3. **SEP****.cnf.xml**

> **Remarque :** De nombreux tutoriels en ligne mentionnent des fichiers `.cnf` à la place de `.cnf.xml`. Dans la pratique, après réinitialisation, ce sont bien les `.cnf.xml` qui fonctionnent.

### 3.1 Fichier `XMLDefault.cnf.xml`

```xml
<Default>
   <callManagerGroup>
     <members>
       <member priority="0">
         <callManager>
           <ports>
             <ethernetPhonePort>2000</ethernetPhonePort>
             <mgcpPorts>
               <listen>2427</listen>
               <keepAlive>2428</keepAlive>
             </mgcpPorts>
           </ports>
           <processNodeName>!!!ASTERISK!!!</processNodeName>
         </callManager>
       </member>
     </members>
   </callManagerGroup>
   <loadInformation434 model="Cisco 7942">!!!VERSION!!!</loadInformation434>
   <authenticationURL></authenticationURL>
   <directoryURL></directoryURL>
   <idleURL></idleURL>
   <informationURL></informationURL>
   <messagesURL></messagesURL>
   <servicesURL></servicesURL>
</Default>
```

- **Ligne 13** : Remplacez `!!!ASTERISK!!!` par l’IP ou le FQDN de votre serveur Asterisk.
- **Ligne 18** : Remplacez `!!!VERSION!!!` par la version de votre firmware (par exemple : `SIP42.9-4-2SR3-1S`). Vous pouvez la repérer via :
  ```bash
  ls SIP*.loads | sed 's/\\.loads//'
  ```

### 3.2 Fichier `dialplan.xml`

```xml
<DIALTEMPLATE>
  <TEMPLATE MATCH="...." Timeout="0"/>
</DIALTEMPLATE>
```

- Le champ `MATCH="...."` représente ici un masque de numérotation sur 4 chiffres.
- Vous pouvez créer plusieurs dialplans (ex. `dialplan1.xml`, `dialplan2.xml`) si chaque téléphone requiert un plan de numérotation différent.

### 3.3 Fichier `SEP<MAC>.cnf.xml`

Ce fichier est crucial pour la configuration SIP et doit inclure l’adresse MAC du téléphone dans son nom, par exemple `SEP001122334455.cnf.xml`.

```xml
<device>
  <deviceProtocol>SIP</deviceProtocol>
  <sshUserId>cisco</sshUserId>
  <sshPassword>cisco</sshPassword>
  <devicePool>
    <dateTimeSetting>
      <dateTemplate>D.M.Y</dateTemplate>
      <timeZone>E. Europe Standard/Daylight Time</timeZone>
      <ntps>
        <ntp>
          <name>!!!NTP!!!</name>
          <ntpMode>Unicast</ntpMode>
        </ntp>
      </ntps>
    </dateTimeSetting>
    <callManagerGroup>
      <members>
        <member priority="0">
          <callManager>
            <ports>
              <ethernetPhonePort>2000</ethernetPhonePort>
              <sipPort>5060</sipPort>
              <securedSipPort>5061</securedSipPort>
            </ports>
            <processNodeName>!!!ASTERISK!!!</processNodeName>
          </callManager>
        </member>
      </members>
    </callManagerGroup>
  </devicePool>
  <sipProfile>
    <sipProxies>
      <backupProxy></backupProxy>
      <backupProxyPort></backupProxyPort>
      <emergencyProxy></emergencyProxy>
      <emergencyProxyPort></emergencyProxyPort>
      <outboundProxy></outboundProxy>
      <outboundProxyPort></outboundProxyPort>
      <registerWithProxy>true</registerWithProxy>
    </sipProxies>
    <sipCallFeatures>
      <cnfJoinEnabled>true</cnfJoinEnabled>
      <callForwardURI>x-cisco-serviceuri-cfwdall</callForwardURI>
      <callPickupURI>x-cisco-serviceuri-pickup</callPickupURI>
      <callPickupListURI>x-cisco-serviceuri-opickup</callPickupListURI>
      <callPickupGroupURI>x-cisco-serviceuri-gpickup</callPickupGroupURI>
      <meetMeServiceURI>x-cisco-serviceuri-meetme</meetMeServiceURI>
      <abbreviatedDialURI>x-cisco-serviceuri-abbrdial</abbreviatedDialURI>
      <rfc2543Hold>false</rfc2543Hold>
      <callHoldRingback>2</callHoldRingback>
      <localCfwdEnable>true</localCfwdEnable>
      <semiAttendedTransfer>true</semiAttendedTransfer>
      <anonymousCallBlock>2</anonymousCallBlock>
      <callerIdBlocking>2</callerIdBlocking>
      <dndControl>0</dndControl>
      <remoteCcEnable>true</remoteCcEnable>
    </sipCallFeatures>
    <sipStack>
      <sipInviteRetx>6</sipInviteRetx>
      <sipRetx>10</sipRetx>
      <timerInviteExpires>180</timerInviteExpires>
      <timerRegisterExpires>3600</timerRegisterExpires>
      <timerRegisterDelta>5</timerRegisterDelta>
      <timerKeepAliveExpires>120</timerKeepAliveExpires>
      <timerSubscribeExpires>120</timerSubscribeExpires>
      <timerSubscribeDelta>5</timerSubscribeDelta>
      <timerT1>500</timerT1>
      <timerT2>4000</timerT2>
      <maxRedirects>70</maxRedirects>
      <remotePartyID>true</remotePartyID>
      <userInfo>None</userInfo>
    </sipStack>
    <autoAnswerTimer>1</autoAnswerTimer>
    <autoAnswerAltBehavior>false</autoAnswerAltBehavior>
    <autoAnswerOverride>true</autoAnswerOverride>
    <transferOnhookEnabled>false</transferOnhookEnabled>
    <enableVad>false</enableVad>
    <preferredCodec>g711alaw</preferredCodec>
    <dtmfAvtPayload>101</dtmfAvtPayload>
    <dtmfDbLevel>3</dtmfDbLevel>
    <dtmfOutofBand>avt</dtmfOutofBand>
    <alwaysUsePrimeLine>false</alwaysUsePrimeLine>
    <alwaysUsePrimeLineVoiceMail>false</alwaysUsePrimeLineVoiceMail>
    <kpml>3</kpml>
    <natEnabled>false</natEnabled>
    <natAddress></natAddress>
    <phoneLabel>!!!NOM!!!</phoneLabel>
    <stutterMsgWaiting>0</stutterMsgWaiting>
    <callStats>false</callStats>
    <silentPeriodBetweenCallWaitingBursts>10</silentPeriodBetweenCallWaitingBursts>
    <disableLocalSpeedDialConfig>false</disableLocalSpeedDialConfig>
    <startMediaPort>16384</startMediaPort>
    <stopMediaPort>32766</stopMediaPort>
    <sipLines>
      <line button="1">
        <featureID>9</featureID>
        <featureLabel>!!!UTILISATEUR!!!</featureLabel>
        <proxy>USECALLMANAGER</proxy>
        <port>5060</port>
        <name>!!!UTILISATEUR!!!</name>
        <displayName>!!!UTILISATEUR!!!</displayName>
        <autoAnswer>
          <autoAnswerEnabled>2</autoAnswerEnabled>
        </autoAnswer>
        <callWaiting>3</callWaiting>
        <authName>!!!UTILISATEUR!!!</authName>
        <authPassword>!!!MOTDEPASSE!!!</authPassword>
        <sharedLine>false</sharedLine>
        <messageWaitingLampPolicy>1</messageWaitingLampPolicy>
        <messagesNumber>*97</messagesNumber>
        <ringSettingIdle>4</ringSettingIdle>
        <ringSettingActive>5</ringSettingActive>
        <contact>!!!UTILISATEUR!!!</contact>
        <forwardCallInfoDisplay>
          <callerName>true</callerName>
          <callerNumber>true</callerNumber>
          <redirectedNumber>true</redirectedNumber>
          <dialedNumber>true</dialedNumber>
        </forwardCallInfoDisplay>
      </line>
    </sipLines>
    <voipControlPort>5060</voipControlPort>
    <dscpForAudio>184</dscpForAudio>
    <ringSettingBusyStationPolicy>0</ringSettingBusyStationPolicy>
    <dialTemplate>dialplan.xml</dialTemplate>
  </sipProfile>
  <commonProfile>
    <phonePassword>1234</phonePassword>
    <backgroundImageAccess>true</backgroundImageAccess>
    <callLogBlfEnabled>2</callLogBlfEnabled>
  </commonProfile>
  <loadInformation>!!!VERSION!!!</loadInformation>
  <vendorConfig>
    <disableSpeaker>false</disableSpeaker>
    <disableSpeakerAndHeadset>false</disableSpeakerAndHeadset>
    <pcPort>1</pcPort>
    <settingsAccess>1</settingsAccess>
    <garp>0</garp>
    <voiceVlanAccess>0</voiceVlanAccess>
    <videoCapability>0</videoCapability>
    <autoSelectLineEnable>0</autoSelectLineEnable>
    <sshAccess>0</sshAccess>
    <sshPort>22</sshPort>
    <webAccess>0</webAccess>
    <spanToPCPort>1</spanToPCPort>
    <loggingDisplay>1</loggingDisplay>
    <loadServer></loadServer>
  </vendorConfig>
  <versionStamp></versionStamp>
  <userLocale>
    <name>French_France</name>
    <langCode>fr</langCode>
  </userLocale>
  <networkLocale>France</networkLocale>
  <networkLocaleInfo>
    <name>France</name>
  </networkLocaleInfo>
  <deviceSecurityMode>1</deviceSecurityMode>
  <authenticationURL></authenticationURL>
  <directoryURL></directoryURL>
  <idleURL></idleURL>
  <informationURL></informationURL>
  <messagesURL></messagesURL>
  <proxyServerURL></proxyServerURL>
  <servicesURL></servicesURL>
  <dscpForSCCPPhoneConfig>96</dscpForSCCPPhoneConfig>
  <dscpForSCCPPhoneServices>0</dscpForSCCPPhoneServices>
  <dscpForCm2Dvce>96</dscpForCm2Dvce>
  <transportLayerProtocol>2</transportLayerProtocol>
  <capfAuthMode>0</capfAuthMode>
  <capfList>
    <capf>
      <phonePort>3804</phonePort>
    </capf>
  </capfList>
  <certHash></certHash>
  <encrConfig>false</encrConfig>
</device>
```

Dans ce fichier, remplacez :

- `!!!NTP!!!` : l’IP ou FQDN de votre **Serveur NTP**.
- `!!!ASTERISK!!!` : l’IP ou FQDN de votre **Serveur Asterisk**.
- `!!!NOM!!!` : le nom convivial de votre téléphone.
- `!!!UTILISATEUR!!!` : l’utilisateur SIP configuré sur Asterisk.
- `!!!MOTDEPASSE!!!` : le mot de passe SIP correspondant.
- `!!!VERSION!!!` : la version du firmware (exemple : `SIP42.9-4-2SR3-1S`).

> **Important** : Vous devez créer un fichier `dialplan.xml` pour chaque téléphone si leur plan de numérotation diffère et ajuster la balise `<dialTemplate>` en conséquence.

---

## 4. Configuration d’Asterisk

### 4.1 Fichier `sip.conf`

Exemple de configuration pour deux postes SIP :

```ini
[7001] ; Section pour l’extension SIP 7001
type=friend ; "friend" permet à la fois l’enregistrement entrant et sortant
username=7001 ; Nom d’utilisateur SIP
secret=123 ; Mot de passe d’authentification SIP
callerid=7001 <7001> ; Identification de l’appelant
context=internal ; Contexte dialplan dans lequel l’appel sera traité
nat=no ; Indique que le téléphone n’est pas derrière NAT
canreinvite=no ; Empêche la re-négociation directe du média entre pairs (Asterisk reste au centre)
host=dynamic ; Le téléphone enregistrera son IP dynamiquement
qualify=yes ; Active le suivi de présence (PING SIP)

[7002] ; Section pour l’extension SIP 7002
type=friend ; "friend" permet les enregistrements et appels entrants/sortants
username=7002 ; Nom d’utilisateur SIP
secret=456 ; Mot de passe d’authentification SIP
callerid=7002 <7002> ; Identification de l’appelant
context=internal ; Contexte dialplan dans lequel l’appel sera traité
nat=no ; Indique qu’il n’y a pas de NAT
canreinvite=no ; Empêche la re-négociation directe du média
host=dynamic ; Enregistrement nécessaire pour connaître son IP
qualify=yes ; Vérifie la qualité du lien avec des paquets SIP
```

### 4.2 Fichier `extensions.conf`

Dans le contexte `[internal]`, configurez vos postes :

```ini
[internal] ; Contexte principal pour les extensions internes
exten => 7001,1,Answer()            ; Répond à l’appel immédiatement
exten => 7001,2,Dial(SIP/7001,20)   ; Compose l’extension SIP/7001 pendant 20 secondes
exten => 7001,3,Playback(vm-nobodyavail) ; Joue un message indiquant que personne n’est disponible
exten => 7001,4,VoiceMail(7001@main); Redirige vers la messagerie vocale associée à l’extension 7001
exten => 7001,5,Hangup()            ; Raccroche l’appel

exten => 7002,1,Answer()            ; Répond à l’appel immédiatement
exten => 7002,2,Dial(SIP/7002,20)   ; Compose l’extension SIP/7002 pendant 20 secondes
exten => 7002,3,Playback(vm-nobodyavail) ; Joue un message indiquant que personne n’est disponible
exten => 7002,4,VoiceMail(7002@main); Redirige vers la messagerie vocale associée à l’extension 7002
exten => 7002,5,Hangup()            ; Raccroche l’appel
```

### 4.3 Fichier `voicemail.conf`

Activez la boîte vocale pour chaque extension :

```ini
[main]
7001 => 123
7002 => 456
```

---

## 5. Vérification du Service

1. Retournez dans la console Asterisk :

```bash
sudo asterisk -rvvv
```

2. Assurez-vous que le module SIP est chargé :

```bash
module load chan_sip.so
```

3. Rechargez la configuration :

```bash
core reload
```

4. Vérifiez la présence de vos téléphones :

```bash
sip show peers
```

Si tout est correct, vous devriez voir vos téléphones **7001** et **7002** apparaître comme *Registered*. Vous pouvez maintenant passer des appels internes et profiter des fonctionnalités de la messagerie vocale.

---

## Conclusion

Vous avez désormais un **serveur Asterisk 18.x** opérationnel, avec des téléphones Cisco configurés via TFTP/DHCP et les bons fichiers XML. Vous pouvez adapter cette configuration en fonction de vos besoins (ajout d’extensions, mise en place de plans de numérotation avancés, etc.).

**Bon déploiement !**

