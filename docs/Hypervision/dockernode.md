# Créer une application Node.js avec Docker

Ce guide explique comment créer une application Node.js et la faire fonctionner dans un conteneur Docker.

---

## **Étape 1 : Créer le répertoire de l'application**
Créez un dossier pour votre projet et accédez-y dans votre terminal.

```bash
mkdir my-node-app
cd my-node-app
```

---

## **Étape 2 : Initialiser le projet Node.js**
Initialisez un nouveau projet Node.js avec npm :

```bash
npm init -y
```

Ce fichier contient les métadonnées de votre projet, telles que son nom et ses dépendances.

---

## **Étape 3 : Créer le fichier principal**
Créez un fichier `app.js` avec ce contenu :

```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Bonjour, Docker et Node.js!');
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Serveur lancé sur le port ${PORT}`);
});
```

---

## **Étape 4 : Installer les dépendances**
Ajoutez Express, un framework minimaliste pour Node.js :

```bash
npm install express
```

---

## **Étape 5 : Tester l'application localement**
Pour tester votre application en dehors de Docker, exécutez-la avec Node.js :

```bash
node app.js
```

Ensuite, ouvrez votre navigateur et accédez à `http://localhost:3000`. Vous devriez voir le message suivant :

> **Bonjour, Docker et Node.js!**

---

## **Étape 6 : Créer le fichier Dockerfile**
Ajoutez un fichier `Dockerfile` pour définir l'environnement de votre application :

```Dockerfile
# Utiliser une image Node.js officielle
FROM node:16

# Définir le répertoire de travail
WORKDIR /usr/src/app

# Copier les fichiers package.json et installer les dépendances
COPY package*.json ./
RUN npm install

# Copier tout le code dans le conteneur
COPY . .

# Exposer le port 3000
EXPOSE 3000

# Démarrer l'application
CMD ["node", "app.js"]
```

---

## **Étape 7 : Construire l'image Docker**
Dans le répertoire de votre projet, exécutez cette commande pour créer une image Docker :

```bash
docker build -t my-node-app .
```

---

## **Étape 8 : Lancer le conteneur**
Pour exécuter l'application dans un conteneur, utilisez la commande suivante :

```bash
docker run -p 3000:3000 my-node-app
```

L'application est maintenant accessible à l'adresse suivante : [http://localhost:3000](http://localhost:3000).

---

## **Étape 9 : Arrêter le conteneur**
Pour arrêter le conteneur, trouvez son ID avec :

```bash
docker ps
```

Puis arrêtez-le avec :

```bash
docker stop <container-id>
```

---

## **Étape 10 : Tester l'application**
Pour vérifier que tout fonctionne, ouvrez un navigateur ou utilisez une commande `curl` :

```bash
curl http://localhost:3000
```

Vous devriez voir :

> **Bonjour, Docker et Node.js!**

---

Vous avez maintenant une application Node.js fonctionnant dans Docker ! 🎉