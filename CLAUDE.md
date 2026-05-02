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

```
xstream-player-ios       (iOS / iPadOS)
xstream-player-tvos      (tvOS)
xstream-player-macos     (macOS)
xstream-playerTests      (tests unitaires partagés)
xstream-playerUITests    (tests UI partagés)
```

### Structure des fichiers

```
xstream-player/
├── App/
│   ├── xstream_playerApp.swift          (iOS @main)
│   ├── xstream_player_tvosApp.swift     (tvOS @main)
│   ├── xstream_player_macosApp.swift    (macOS @main)
│   └── ContentView.swift                (dispatcher AppPhase + #if os())
│
├── Shared/
│   ├── Models/
│   │   ├── MediaItem.swift              (JellyfinItem brut + MediaItem propre + ImageType)
│   │   ├── AuthCredentials.swift        (struct Codable stockée en Keychain)
│   │   └── ItemFilter.swift             (enum pour query params Jellyfin)
│   │
│   ├── Services/
│   │   ├── APIClient.swift              (singleton, request<T> + rawRequest)
│   │   ├── APIClient+Auth.swift         (authenticate, validateToken)
│   │   ├── APIClient+Media.swift        (fetchItems, fetchLibraries, fetchImageItem, etc.)
│   │   ├── AuthService.swift            (singleton @Observable @MainActor, wrap Keychain)
│   │   ├── KeychainStore.swift          (lecture/écriture/suppression Keychain Security)
│   │   └── PlayerService.swift          (vide — non implémenté)
│   │
│   ├── ViewModels/
│   │   ├── MediaLibrary.swift           (@Observable, items + resumables + lastFilms + images)
│   │   ├── MediaFolder.swift            (@Observable, liste des bibliothèques Jellyfin)
│   │   └── JellyfinUser.swift           (struct Decodable réponse GET /Users/Me)
│   │
│   ├── AppState/
│   │   ├── AppState.swift               (@Observable @MainActor, cycle de vie global)
│   │   ├── AppPhase.swift               (enum: launching | needsAuth | ready | error)
│   │   └── AppError.swift               (enum: serverUnreachable | unauthorized | timeout)
│   │
│   └── Views/
│       ├── AppTheme.swift               (design tokens : couleurs, typo, spacing, radius)
│       ├── AppTopBar.swift              (barre custom : titre + AvatarBadge)
│       ├── HomeTabView.swift            (onglet accueil : hero + reprendre + derniers films)
│       ├── MediaDetailView.swift        (fiche détail : hero image + infos + casting mock)
│       ├── HeroCard.swift               (carte featured sur HomeTabView)
│       ├── PosterCard.swift             (carte poster dans les scrolls horizontaux)
│       ├── LoginView.swift              (formulaire login Jellyfin)
│       ├── SplashView.swift             (écran de démarrage)
│       └── ErrorView.swift              (écran d'erreur avec retry/logout)
│
├── iOS/Views/
│   └── MobilePlayerView.swift           (TabView 4 onglets iOS)
│
├── tvOS/Views/
│   └── TVPlayerView.swift               (placeholder tvOS)
│
└── macOS/Views/
    └── DesktopPlayerView.swift          (placeholder macOS)
```

### Règles de Target Membership

- `App/*App.swift` → target plateforme correspondant uniquement
- `App/ContentView.swift` → les 3 targets
- `Shared/**` → les 3 targets
- `iOS/Views/**` → iOS uniquement
- `tvOS/Views/**` → tvOS uniquement
- `macOS/Views/**` → macOS uniquement

---

## Circulation des données

### 1. Démarrage de l'app

```
@main App
  └── AppState.bootstrap()   [async, @MainActor]
        ├── AuthService.hasValidToken?  ← lit Keychain via KeychainStore
        │     NON → phase = .needsAuth
        │     OUI → APIClient.validateToken()  → GET /Users/Me
        │               OK  → phase = .ready
        │               401 → phase = .error(.unauthorized)
        │               err → phase = .error(.serverUnreachable)
        └── délai minimum 1.5s (splash visible)
```

### 2. Authentification

```
LoginView
  └── APIClient.authenticate(serverUrl, username, password)
        POST /Users/AuthenticateByName
        → AuthResponse { AccessToken, User { Id, Name } }
        → AuthCredentials { jellyfinBaseUrl, accessToken, userId, username }
        → AuthService.save(credentials)  → Keychain (JSONEncoder + SecItemAdd/Update)
        → AppState.didAuthenticate()  → phase = .ready
```

### 3. Navigation iOS (phase = .ready)

```
MobilePlayerView  (@State folder: MediaFolder)
  ├── Tab "Accueil"    → HomeTabView
  ├── Tab "Librairie"  → LibraryTabView (placeholder)
  ├── Tab "Téléchargés"→ DownloadsTabView (placeholder)
  └── Tab "Recherche"  → NavigationStack + .searchable (placeholder)
```

### 4. Chargement HomeTabView

```
HomeTabView
  ├── Paramètres reçus : username: String, libraries: [MediaItem]  ← inutilisé dans le body
  ├── @Environment(MediaLibrary.self) library  ← ⚠️ NON injecté dans l'environnement
  │
  └── .task { loadItems + loadResumableItems + loadLastFilmItems } [3 appels parallèles]
        ├── library.loadItems(userId)
        │     GET /Users/{id}/Items?Recursive=true&IncludeItemTypes=Movie,Series,Episode
        │     → [JellyfinItem] → [MediaItem]  → library.items
        │
        ├── library.loadResumableItems(userId)
        │     GET /Users/{id}/Items?Filters=IsResumable&Fields=UserData,RunTimeTicks...
        │     → library.resumables
        │
        └── library.loadLastFilmItems(userId)
              GET /Users/{id}/Items?IncludeItemTypes=Movie&SortBy=DateCreated&Limit=5
              → library.lastFilms
```

### 5. Chargement des images (lazy, par item)

```
Chaque card dans la vue → .task { library.loadImage*(itemId, imageType) }
  └── APIClient.fetchImageItem(imageType, itemId)
        GET /Items/{itemId}/Images/{Primary|Thumb|Banner}
        → Data brute (pas JSON)
        → mutation : library.items[index].image = data   ← struct mutation via index
```

Pas de cache — les images sont re-fetchées à chaque apparition de la vue.

### 6. Navigation vers MediaDetailView

```
Tap sur item → selectedItem = item → .fullScreenCover
  └── MediaDetailView(item: MediaItem)
        ├── item.image utilisée comme fallback backdrop (image Primary déjà chargée)
        └── .task → APIClient.fetchImageItem(imageType: .banner, itemId)
                    GET /Items/{id}/Images/Banner
                    → backdropData: Data?  (affiché dans heroSection)
```

### 7. Couche transport (APIClient)

```
APIClient.shared  (singleton, pas @Observable)
  ├── request<T: Decodable>()   → URLSession + decode JSON
  └── rawRequest()              → URLSession + retourne Data brute (images)

Headers automatiques (via AuthService.shared @MainActor) :
  Authorization: MediaBrowser Client="...", Token="<accessToken>"
  X-Emby-Token: <accessToken>
  X-Emby-Device-Id: UUID persisté dans UserDefaults
```

---

## Problèmes et incohérences actuels

| Problème | Fichier | Description |
|----------|---------|-------------|
| `@Environment(MediaLibrary.self)` non injecté | `HomeTabView.swift` | La vue utilise `library` via environment mais `MobilePlayerView` n'injecte pas l'objet → crash à runtime |
| `libraries: [MediaItem]` inutilisé | `HomeTabView.swift` | Paramètre passé depuis `folder.libraries` mais jamais utilisé dans le body |
| `MediaFolder` utilisé mais résultat ignoré | `MobilePlayerView.swift` | `folder.loadLibraries()` est appelé, le résultat est passé à `HomeTabView` mais non consommé |
| Pas de cache image | `MediaLibrary.swift` | Chaque image est re-fetchée à chaque rendu de la vue |
| Images stockées dans `MediaItem.image: Data?` | `MediaItem.swift` | Stockage en mémoire sans limite, pas adapté à une grande bibliothèque |
| `PlayerService` vide | `PlayerService.swift` | Aucune implémentation |
| Cast mock | `MediaDetailView.swift` | `mockCast` hardcodé, pas de fetch `Fields=People` depuis l'API |

---

## Endpoints Jellyfin implémentés

```
POST /Users/AuthenticateByName              → authenticate()
GET  /Users/Me                              → validateToken()
GET  /Library/MediaFolders                  → fetchLibraries()
GET  /Users/{id}/Items                      → fetchItems(), fetchResumableItems(), fetchLastFilmItems()
GET  /Items/{id}/Images/{Primary|Thumb|Banner|Backdrop} → fetchImageItem()
```

Non implémentés :
```
GET  /Videos/{id}/master.m3u8               → stream HLS (PlayerService vide)
GET  /Users/{id}/Items/{id}/PlaybackInfo    → infos lecture
POST /Sessions/Playing                      → reporting de lecture
GET  /Items/{id}?Fields=People              → casting réel
```

---

## Conventions et choix techniques

### SwiftUI moderne uniquement

- ✅ `@Observable` (Swift 5.9+) pour les ViewModels — pas `ObservableObject`
- ✅ `@Environment(MyType.self)` pour l'injection
- ✅ `.task {}` pour les appels async (pas `.onAppear`)
- ✅ `Tab("label", systemImage:, value:)` + `Tab(role: .search)` (iOS 18+)
- ✅ `NavigationStack` — pas `NavigationView`
- ✅ `.toolbarBackground` / `.toolbarColorScheme` pour le theming des barres

### Navigation iOS

```
TabView(selection: $selectedTab)
  ├── Tab(..., value: .home)    → HomeTabView
  ├── Tab(..., value: .library) → LibraryTabView
  ├── Tab(..., value: .downloads) → DownloadsTabView
  └── Tab(value: .search, role: .search)
        NavigationStack + .searchable(isPresented: $isSearchActive)
        .onChange(selectedTab == .search) → isSearchActive = true
```

### Concurrence

- Swift 6 strict concurrency
- `@MainActor` sur `AppState` et `AuthService`
- `APIClient` n'est pas `@Observable` — c'est un service pur sans état UI
- `async let` pour paralléliser les chargements dans les vues

### Modèles de données

- `JellyfinItem: Decodable` → réponse JSON brute (PascalCase)
- `MediaItem` → modèle interne propre, initialisé depuis `JellyfinItem`
- `MediaItem.image: Data?` → image binaire stockée inline (à refactorer)
- `AuthCredentials: Codable` → stocké en Keychain (JSONEncoder)

### Layout / Images

- Images en background → toujours via `.background {}`, jamais dans un ZStack comme enfant direct, pour éviter que l'image dicte la taille du layout
- `scaledToFill()` utilisé uniquement dans un `.background {}` ou avec frame explicite + `.clipped()`

---

## Design system (AppTheme)

```swift
AppTheme.Colors.background   // #0A0618 — fond principal
AppTheme.Colors.surface      // #120C26 — cartes/surfaces
AppTheme.Colors.accent       // #A78BFA — violet principal
AppTheme.Colors.primary      // #3B8DEF — bleu action (play, CTA)
AppTheme.Colors.danger       // #F05757 — erreur/favori actif
AppTheme.Colors.gradientStart/End  // violet foncé → violet clair

AppTheme.Typography.display   // 36pt heavy
AppTheme.Typography.heading1  // 17pt bold
AppTheme.Typography.body      // 13pt regular
AppTheme.Typography.tiny      // 11pt regular

AppTheme.Spacing.xs/sm/md/lg/xl  // 8/16/24/30/40
AppTheme.Radius.card/button/pill  // 12/14/100
```

---

## État actuel du projet

### Implémenté et fonctionnel
- [x] Auth complète : login/password → Keychain → validation token au démarrage
- [x] `APIClient` : request générique, headers Jellyfin, gestion erreurs
- [x] `AppState` : cycle de vie (splash → auth → ready → error)
- [x] Navigation iOS : TabView natif 4 onglets, search avec `Tab(role: .search)`
- [x] `HomeTabView` : hero card + section "reprendre" + section "derniers films"
- [x] `MediaDetailView` : hero backdrop + infos + synopsis expansible + boutons action
- [x] `PosterCard` : carte poster avec progress bar, badges, états focused
- [x] `HeroCard` : carte featured avec boutons Lire/Liste/Info

### Incomplet / cassé
- [ ] `HomeTabView` : `@Environment(MediaLibrary.self)` non injecté → crash
- [ ] `LibraryTabView` : placeholder vide
- [ ] `DownloadsTabView` : placeholder vide
- [ ] `SearchTabView` : placeholder vide (searchable câblé mais pas de résultats)
- [ ] `PlayerService` : vide, aucune lecture vidéo
- [ ] Cast dans `MediaDetailView` : données mock hardcodées

### À venir
- [ ] Refacto data flow : injection propre de `MediaLibrary` via environment
- [ ] Cache images (NSCache ou stockage disque)
- [ ] Lecture vidéo : AVPlayer + HLS + reporting session Jellyfin
- [ ] LibraryTabView : grille de films/séries filtrables
- [ ] SearchTabView : résultats de recherche en temps réel
- [ ] DownloadsTabView : gestion offline
- [ ] Adaptation tvOS : focus engine, layouts spécifiques
- [ ] Menus et raccourcis macOS

---

## Préférences pour les réponses

- Code Swift complet et compilable, pas de pseudo-code
- Préciser dans quel fichier va le code
- Pour les nouveaux concepts Swift : explication courte avec parallèle JS/TS si pertinent
- Patterns modernes uniquement (Swift 5.9+, SwiftUI iOS 18+, Swift 6 concurrency)
- Pas de boilerplate inutile
