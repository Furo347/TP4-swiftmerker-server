# SwiftMarket

SwiftMarket est un projet Swift full-stack composé de:

- un serveur REST construit avec Vapor et Fluent (SQLite)
- un client CLI construit avec ArgumentParser

Le dépôt est organisé en mode monorepo avec deux packages Swift indépendants:

- `Server/`: API backend
- `Client/`: CLI pour interagir avec l'API

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Démarrage rapide](#démarrage-rapide)
- [Utilisation du client CLI](#utilisation-du-client-cli)
- [API exposée](#api-exposée)
- [Tests](#tests)
- [Docker](#docker)
- [Dépannage](#dépannage)

## Fonctionnalités

- Gestion des utilisateurs: création, listing, détail
- Gestion des annonces: création, listing paginé, détail, suppression
- Filtres sur les annonces: `category` et `query`
- Validation des entrées côté API
- Persistance locale avec SQLite (`db.sqlite`)

## Architecture

### Server

- Framework: Vapor 4
- ORM: Fluent
- Base de données: SQLite
- Dossier principal: `Server/Sources/SwiftmarketServer/`

Composants clés:

- `Controllers/`: logique HTTP (`UserController`, `ListingController`)
- `Models/`: modèles Fluent (`User`, `Listing`)
- `DTOs/`: objets de requête/réponse
- `Migrations/`: schéma de base de données

### Client

- Framework CLI: Swift ArgumentParser
- Dossier principal: `Client/Sources/SwiftMarketClient/`

Composants clés:

- `Commands/`: commandes CLI utilisateurs/annonces
- `API/`: client HTTP + gestion d'erreurs
- `Models/`: structures de sérialisation

## Prérequis

- Swift 5.9+ pour le client
- Swift 6.0+ recommandé pour le serveur
- macOS ou Linux

Vérifier votre version:

```bash
swift --version
```

## Démarrage rapide

### 1) Lancer le serveur

```bash
cd Server
swift run
```

Le serveur démarre par défaut sur `http://127.0.0.1:8080`.

### 2) Utiliser le client

Dans un second terminal:

```bash
cd Client
swift run SwiftMarketClient users
```

## Utilisation du client CLI

Afficher l'aide:

```bash
cd Client
swift run SwiftMarketClient --help
```

### Commandes utilisateurs

Créer un utilisateur:

```bash
swift run SwiftMarketClient create-user --username alice --email alice@example.com
```

Lister les utilisateurs:

```bash
swift run SwiftMarketClient users
```

Voir un utilisateur:

```bash
swift run SwiftMarketClient user <USER_UUID>
```

Lister les annonces d'un utilisateur:

```bash
swift run SwiftMarketClient user-listings <USER_UUID>
```

### Commandes annonces

Créer une annonce:

```bash
swift run SwiftMarketClient post \
	--title "MacBook Pro" \
	--desc "14 pouces, très bon état" \
	--price 1999.99 \
	--category electronics \
	--seller <USER_UUID>
```

Lister les annonces (paginé):

```bash
swift run SwiftMarketClient listings --page 1
```

Filtrer par catégorie:

```bash
swift run SwiftMarketClient listings --category electronics
```

Filtrer par texte:

```bash
swift run SwiftMarketClient listings --query "mac"
```

Voir une annonce:

```bash
swift run SwiftMarketClient listing <LISTING_UUID>
```

Supprimer une annonce:

```bash
swift run SwiftMarketClient delete <LISTING_UUID>
```

Catégories acceptées:

- `electronics`
- `clothing`
- `furniture`
- `other`

## API exposée

Base URL locale: `http://localhost:8080`

### Utilisateurs

- `POST /users`
- `GET /users`
- `GET /users/:userID`
- `GET /users/:userID/listings`

### Annonces

- `POST /listings`
- `GET /listings?page=1&category=electronics&query=mac`
- `GET /listings/:listingID`
- `DELETE /listings/:listingID`

## Tests

Depuis `Server/`:

```bash
swift test
```

## Docker

Depuis `Server/`:

```bash
docker compose build
docker compose up app
```

Le port exposé est `8080:8080`.

Arrêter:

```bash
docker compose down
```

## Dépannage

### Port 8080 déjà utilisé

Identifier le process:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

Libérer le port:

```bash
fuser -k 8080/tcp
```

### Le client ne se connecte pas

- Vérifier que le serveur est bien lancé
- Vérifier l'URL utilisée par le client (par défaut `http://localhost:8080`)

---

Projet basé sur Swift, Vapor et ArgumentParser.
