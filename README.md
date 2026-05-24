# Paws & Pebbles

A deeply personal iOS app built for the one person who matters most. Every memory is a pebble, every moment a stone in the river of your story together.

---

## The Story Behind the Name

- **Paws** — She has a tattoo of two paw prints from her puppies who passed away. They are always with her.
- **Pebbles** — She studied geology and loves collecting rocks everywhere she goes. Every shared memory in this app is represented as a pebble.

---

## Screenshots

<!-- Take screenshots on your phone and add them to Assets/Screenshots/ -->
<!-- Then uncomment the block below and update the filenames -->
<!--
<p align="center">
  <img src="Assets/Screenshots/home.png" width="200" />
  <img src="Assets/Screenshots/lock.png" width="200" />
  <img src="Assets/Screenshots/timeline.png" width="200" />
  <img src="Assets/Screenshots/settings.png" width="200" />
</p>
-->

*Screenshots coming soon*

---

## Features

### Home
- Full-screen couple photo with **3D parallax effect** (gyroscope-driven)
- Photo picker with drag-to-reposition editor
- **Daily Pebble** — a unique love note that changes each day
- Live **"Together For"** timer ticking in real time
- Countdown cards for anniversary and birthday
- Scroll-reveal animations with 3D entrance effects

### Liquid Glass Navigation Bar
- Floating pill tab bar using Apple's **Liquid Glass** API (iOS 26)
- Draggable glass bubble with icon carousel transitions
- Teal-tinted glass with refraction effects between tabs
- Edge swipe to navigate between pages
- Auto-hides on scroll, reappears at top

### Timeline
- Snap-to-center carousel with depth scaling
- Fold/unfold memory containers
- Stone type classification (Sandstone, Slate, Mossy, Quartz, Obsidian)
- Photo strips and location tags
- "Explore this memory" with immersive detail view

### Immersive Detail View
- Full-screen hero with horizontal paging between memories
- Photo gallery grid with staggered pop-in animations
- Mood tags with flow layout
- Prev/next navigation with counter

### Security
- PIN lock with **liquid glass numpad** (4-6 digit support)
- Face ID / biometric authentication
- Configurable lock delay (immediately / 30s / 1min / 5min)
- PIN enable/disable toggle

### Love Notes
- Engraved stone cards with gradient backgrounds
- Categories: Love, Gratitude, Memory, Open When, Encouragement
- Filter pills for browsing

### Gallery
- Masonry grid photo albums
- Stone-colored gradient cards

### Settings
- Light / Dark theme toggle
- 3D Parallax toggle
- Haptics toggle
- Daily notification with time picker
- Partner name customization
- Data export and management

---

## Tech Stack

| | |
|---|---|
| **Platform** | iOS 26+ (iPhone only) |
| **Framework** | SwiftUI |
| **Data** | SwiftData |
| **Architecture** | MVVM |
| **Design** | Apple Liquid Glass, custom animations |
| **Fonts** | Cormorant Garamond + Outfit |
| **Motion** | Core Motion (gyroscope parallax) |
| **Auth** | LocalAuthentication (Face ID) + Keychain (PIN) |

---

## Project Structure

```
Paws & Pebbles/
├── App/
│   ├── PawsAndPebblesApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Models/          # SwiftData models (Memory, LoveNote, Album, etc.)
│   ├── Services/        # AuthService, DataService
│   ├── Theme/           # AppColors, AppFonts, AppAnimations, AppHaptics
│   └── Extensions/      # Color+Hex, Date+Formatting
├── Features/
│   ├── Home/            # HomeView, PhotoEditorView, ParallaxMotion
│   ├── Timeline/        # MemoryTimelineView, MemoryContainerView
│   ├── Immersive/       # ImmersiveView, ImmersiveSlideView
│   ├── Navigation/      # MainTabView (Liquid Glass tab bar)
│   ├── Lock/            # LockScreenView
│   ├── Settings/        # SettingsView, GlassPINView
│   ├── Gallery/         # GalleryView
│   ├── Notes/           # NotesListView
│   ├── Surprises/       # SurprisesView
│   └── PawMemorial/     # PawMemorialView
└── Resources/
    ├── Data/            # JSON seed data
    └── Fonts/           # Custom font files
```

---

## Setup

1. Clone the repo
2. Download fonts from Google Fonts:
   - [Cormorant Garamond](https://fonts.google.com/specimen/Cormorant+Garamond) (Light, Regular, Medium, SemiBold, Italic)
   - [Outfit](https://fonts.google.com/specimen/Outfit) (ExtraLight, Light, Regular, Medium)
3. Place `.ttf` files in `Paws & Pebbles/Resources/Fonts/`
4. Open `Paws & Pebbles.xcodeproj` in Xcode 26+
5. Set your signing team
6. Build and run on iPhone

---

## Distribution

Private TestFlight distribution for a single user.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <em>Our story, one pebble at a time.</em>
</p>

---

<p align="center">
  Built by <strong><a href="https://github.com/fcampoverdeg">Felipe Campoverde</a></strong>
</p>

<p align="center">
  Made with all my love for <strong>Natty</strong>.<br/>
  Every line of code, every animation, every pebble — it's all for you.
</p>
