# xstream-player — Contexte projet pour Claude

## Vue d'ensemble

Application native multi-plateforme Apple pour streamer du contenu media depuis un serveur Jellyfin distant. Projet personnel/homelab, pas commercial.

**Plateformes cibles** : iOS, iPadOS, tvOS, macOS
**Stack** : SwiftUI natif (pas Catalyst, pas React Native)
**Backend** : Jellyfin sur serveur distant (API REST + HLS)
**Swift** : Swift 6 strict concurrency
**Xcode** : 26.4.1+

---

## Profil du développeur

- Développeur indépendant freelance, formation **JS/TS** (frameworks JS modernes)
- Backend, SQL, CI/CD, Linux, DevOps OK
- **Apprend Swift/SwiftUI activement** sur ce projet — explications bienvenues sur les concepts spécifiques au langage
- Préfère les parallèles avec **JS/TS/React** quand c'est pertinent pour comprendre rapidement
- Pas besoin de revenir aux bases de la programmation, juste aux spécificités Swift/Apple

---

## Architecture du projet

### Structure des targets

3 targets app séparés, 1 target Tests, 1 target UITests :

```
xstream-player-ios       (iOS / iPadOS)
xstream-player-tvos      (tvOS)
xstream-player-macos     (macOS)
xstream-playerTests      (tests unitaires partagés)
xstream-playerUITests    (tests UI partagés, organisés par plateforme en interne)
```

### Structure des fichiers

```
xstream-player/
├── App/                          # Entry points et dispatcher
│   ├── xstream_playerApp.swift          (iOS @main)
│   ├── xstream_player_tvosApp.swift     (tvOS @main)
│   ├── xstream_player_macosApp.swift    (macOS @main)
│   └── ContentView.swift                (dispatcher #if os())
│
├── Shared/                       # Code commun aux 3 targets
│   ├── Models/                          (MediaItem, JellyfinItem, etc.)
│   ├── Services/                        (APIClient, PlayerService)
│   ├── ViewModels/                      (@Observable classes)
│   └── Extensions/
│
├── iOS/Views/                    # Vues spécifiques iOS/iPadOS
├── tvOS/Views/                   # Vues spécifiques tvOS (focus engine)
├── macOS/Views/                  # Vues spécifiques macOS (menus, raccourcis)
│
└── Resources/
    └── Assets.xcassets
```

### Règles de Target Membership

- `App/*App.swift` → target plateforme correspondant uniquement
- `App/ContentView.swift` → **les 3 targets** (c'est le dispatcher)
- `Shared/**` → **les 3 targets** (toujours)
- `iOS/Views/**` → iOS uniquement
- `tvOS/Views/**` → tvOS uniquement
- `macOS/Views/**` → macOS uniquement
- `Resources/Assets.xcassets` → les 3 targets

---

## Conventions et choix techniques

### SwiftUI moderne uniquement

- ✅ Utiliser **`@Observable`** (macro Swift 5.9+) pour les ViewModels
- ❌ Ne **jamais** utiliser `ObservableObject` + `@Published` (legacy)
- ✅ `NavigationStack` + `navigationDestination(for:)` 
- ❌ Pas de `NavigationView` (deprecated)
- ✅ `.task {}` pour les appels async dans les vues
- ❌ Éviter `.onAppear` pour de l'async (utiliser `.task`)
- ✅ `@State` privé pour l'état local
- ✅ `@Environment(MyType.self)` pour l'injection (nouveau style)

### Concurrence

- Cible **Swift 6 strict concurrency mode**
- Utiliser `actor` pour l'état partagé thread-safe (pas de locks manuels)
- `@MainActor` sur tout ce qui touche à l'UI
- Types `Sendable` partout où c'est possible
- Pas de `@unchecked Sendable` sauf justification précise

### Services réseau

- `URLSession` natif + `async/await` (pas d'Alamofire pour l'instant)
- Generic `request<T: Decodable>` dans `APIClient`
- Erreurs typées via `enum APIError: Error`
- Headers Jellyfin : `X-Emby-Token`, `X-Emby-Device-Name`, etc.

### Player media

- `AVFoundation` + `AVKit` pour la lecture
- HLS natif via `AVPlayer`
- Intégration `MediaPlayer` framework pour Control Center / AirPods
- Adaptation focus engine sur tvOS

### Modèles de données

- `struct` `Decodable` séparée pour la **réponse Jellyfin brute** (PascalCase)
- `struct` interne propre (`MediaItem`) avec `init(from: JellyfinItem)`
- `CodingKeys` pour mapper le PascalCase JSON → camelCase Swift
- `Identifiable` + `Hashable` sur les modèles de vues

### Code style

- Pas de `class` non-`final` sauf héritage explicitement nécessaire
- `private` par défaut, ouvrir uniquement si nécessaire
- Préférer `struct` à `class` sauf besoin de référence partagée
- Pas de force-unwrap (`!`) sauf cas justifiés (par ex. `IBOutlet` legacy)
- Préférer `guard let` à `if let` pour early-return

---

## Backend Jellyfin

### Endpoints utilisés

```
POST /Users/AuthenticateByName        # auth (à implémenter plus tard)
GET  /Users/Me                        # info user courant
GET  /Users/{userId}/Items            # bibliothèque
GET  /Items/{itemId}/Images/Primary   # thumbnails
GET  /Videos/{itemId}/master.m3u8     # stream HLS
```

### Authentification

Phase actuelle : **API Key fixe** stockée dans `APIClient` (usage perso).
Phase future : login username/password avec stockage Keychain.

### Conventions API

- Header `X-Emby-Token` pour l'auth
- Réponses JSON en **PascalCase** (mappage via `CodingKeys`)
- Items principaux : `Movie`, `Series`, `Episode`, `MusicAlbum`

---

## État actuel du projet

### Fait
- [x] Structure multi-target Xcode (iOS/tvOS/macOS)
- [x] Architecture de fichiers (Shared/, iOS/, tvOS/, macOS/)
- [x] ContentView dispatcher cross-plateforme
- [x] `MediaItem` model de base
- [x] `APIClient` (skeleton, à compléter)
- [x] Vues placeholder par plateforme

### En cours
- [ ] `APIClient` complet avec `fetchItems`
- [ ] `MediaLibraryViewModel` (`@Observable`)
- [ ] Vue liste de la bibliothèque

### À venir
- [ ] Player vidéo (AVPlayer + VideoPlayer)
- [ ] Authentification Jellyfin
- [ ] Cache image / thumbnails
- [ ] Adaptation focus engine tvOS
- [ ] Menus & raccourcis macOS
- [ ] Tests unitaires sur `APIClient`

---

## Préférences pour les réponses

- Code Swift complet et compilable, pas de pseudo-code
- Annoter les imports nécessaires
- Préciser dans quel fichier va le code (`Shared/Services/APIClient.swift`)
- Pour les nouveaux concepts Swift : explication courte avec parallèle JS/TS si pertinent
- Privilégier les patterns modernes (Swift 5.9+, SwiftUI moderne, Swift 6 concurrency)
- Pas de boilerplate inutile, code direct et lisible
