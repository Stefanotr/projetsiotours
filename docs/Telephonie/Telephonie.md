# Guide de déploiement – Asterisk 18 & téléphones Cisco (ToIP)

## 1. Contexte : Téléphonie sur IP pour Sportludique


L’entreprise Sportludique a besoin d’assurer une communication rapide et efficace entre ses différents services
sur le site de Tours (Conception, Production, Informatiques). Pour répondre à cette exigence de fluidité, de
fiabilité et d’évolutivité des échanges, la mise en place d’une solution de téléphonie sur IP (ToIP) s’impose.

L’entreprise **Sportludique** vise :

- la **rationalisation** des coûts téléphoniques ;
- la **mobilité** (application Zoiper sur Wi‑Fi dédié) ;
- l’**interopérabilité** entre postes Cisco 79×× et soft‑phones ;
- la **qualité de service** (VLAN 125 voix, SSID ToIP, QoS en cœur).

Le choix s’est porté sur **Asterisk 18** jouant le rôle d’IPBX (SIP), installé sur une VM Debian, et sur des téléphones Cisco 7942G migrés en SIP. Un couple **TFTP + DHCP** fournit le firmware et l’autoprovisioning. 

---

## 2. Procédure de configuration

> Les commandes sont exécutées sous Debian 12 ; adaptez les chemins si nécessaire.

### 2.1 Installation d’Asterisk 18

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install wget build-essential subversion -y
cd /usr/src
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar xzf asterisk-18-current.tar.gz
cd asterisk-18.*

# Dépendances & codecs
sudo contrib/scripts/get_mp3_source.sh
sudo contrib/scripts/install_prereq install           # choisir 33 pour la France

sudo ./configure
sudo make menuselect    # cocher : format_mp3, res_pjsip, app_voicemail
sudo make -j$(nproc)
sudo make install
sudo make samples
sudo make config
sudo ldconfig
```

Créer l’utilisateur dédié :

```bash
sudo adduser --system --group --no-create-home --disabled-login asterisk
sudo chown -R asterisk:asterisk /etc/asterisk /var/{lib,log,run,spool}/asterisk
sudo chmod -R 750 /etc/asterisk
sudo sed -i 's/;\?\(runuser *=\).*/\1 asterisk/'  /etc/asterisk/asterisk.conf
sudo sed -i 's/;\?\(rungroup *=\).*/\1 asterisk/' /etc/asterisk/asterisk.conf
sudo systemctl restart asterisk
```

### 2.2 Services d’autoprovisioning

| Service | Paquet | Rôle | Interface/VLAN |
|---------|--------|------|----------------|
| **DHCP** | isc-dhcp-server | Attribue IP + option 66 → TFTP | VLAN 125 (Voix) |
| **TFTP** | tftpd‑hpa | Diffuse firmware Cisco & XML | VLAN 125 |

**DHCP – extrait /etc/dhcp/dhcpd.conf :**
```dhcp
subnet 192.168.125.0 netmask 255.255.255.0 {
  range 192.168.125.20 192.168.125.99;
  option routers 192.168.125.1;           # SVI ToIP (Asterisk)
  option tftp-server-name "192.168.125.130";  # VM TFTP
  option bootfile-name   "XMLDefault.cnf.xml";
}
```

**TFTP :** placez le firmware (`SIP42.xx.loads`) et les fichiers `XMLDefault.cnf.xml`, `dialplan.xml`, `SEP<MAC>.cnf.xml` dans `/srv/tftp/`.

### 2.3 Configuration des téléphones Cisco

#### 2.3.1 `XMLDefault.cnf.xml`
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
</Default>
```

#### 2.3.2 `dialplan.xml`
```xml
<DIALTEMPLATE>
  <TEMPLATE MATCH="...." Timeout="0"/>
</DIALTEMPLATE>
```

#### 2.3.3 `SEP<MAC>.cnf.xml`
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

### 2.4 Fichiers Asterisk

`/etc/asterisk/sip.conf` – extraits :
```ini
[general]
context=default
bindport=5060
bindaddr=0.0.0.0
language=fr
videosupport=no

[7001](!)
type=friend
host=dynamic
secret=123
context=internal
callerid="Poste 7001" <7001>
qualify=yes

[7002](7001)   ; hérite de la section générique
secret=456
callerid="Poste 7002" <7002>
```

`/etc/asterisk/extensions.conf` – extrait :
```ini
[internal]
exten => _7XXX,1,NoOp(Appel interne vers ${EXTEN})
 same => n,Dial(SIP/${EXTEN},20)
 same => n,VoiceMail(${EXTEN}@main,u)
 same => n,Hangup()
```

`/etc/asterisk/voicemail.conf` :
```ini
[main]
7001 => 123,Poste 7001,,
7002 => 456,Poste 7002,,
```

Appliquer :
```bash
sudo asterisk -rx "module load chan_sip.so"
sudo asterisk -rx "core reload"
```

### 2.5 Tests et supervision

- **Enregistrement :** `asterisk -rx "sip show peers"` → `7001` et `7002` doivent être *OK* (Latency < 100 ms).
- **Appels internes :** décrocher `7001` → composer `7002` → vérifier audio dans les deux sens.
- **QoS** : Sur le switch, tag VLAN 125 et configurer `trust dscp`; vérifier avec `show mls qos interface ...`.

---

## 3. Conclusion

La solution déployée fournit :

- Un **IPBX Asterisk 18** sécurisé, tournant sous utilisateur dédié `asterisk` ;
- Un **provisioning automatique** des téléphones Cisco via DHCP option 66 et TFTP (firmware + XML) ;
- Des **extensions internes** (7001, 7002…) disposant de la messagerie vocale ;
- Un **VLAN voix** isolé (125) garantissant bande passante et latence ;
- Une **mobilité** assurée par l’application Zoiper sur SSID ToIP.

Ce dispositif répond aux exigences de l’évaluation BTS SIO (E6) et peut être étendu (SIP Trunk, IVR, QoS DSCP) pour accompagner la croissance de Sportludique.
