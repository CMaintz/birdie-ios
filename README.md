# Birdie

A birdwatching iOS app built with SwiftUI and Firebase. Log bird sightings at your current location, browse them in a list or on a map, and filter by species, distance, or your own entries.

## Features

- **Authentication** — Register and log in via Firebase Auth
- **Log sightings** — Record a bird species, optional notes, and your GPS location with one tap
- **Sightings list** — Scrollable list of all sightings with swipe-to-delete for your own entries
- **Map view** — See all sightings plotted on an interactive map
- **Filters** — Filter by species, distance from your current location, or show only your own sightings
- **Profile** — View and edit your display name and photo

### Supported species

Robin, Sparrow, Eagle, Bald Eagle, Hawk, Owl, Blackbird, Finch, Woodpecker, Duck, Swan, Pigeon, Parrot, Falcon, Pelican, Kingfisher, Heron, Toucan

## Tech stack

- SwiftUI + Swift Concurrency
- Firebase (Auth, Firestore, Storage)
- MapKit
- [OpenCage Geocoding API](https://opencagedata.com) — reverse geocoding coordinates to readable locations
- [AlertToast](https://github.com/elai950/AlertToast) — in-app toast notifications
- Swift Package Manager

## Requirements

- Xcode 16+
- iOS 17+
- A Firebase project with Auth and Firestore enabled
- An OpenCage API key

## Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd Birdie
   ```

2. **Add your Firebase config**
   ```bash
   cp Birdie/GoogleService-Info.plist.example Birdie/GoogleService-Info.plist
   ```
   Replace the placeholder values with your own from the [Firebase console](https://console.firebase.google.com).

3. **Add your OpenCage API key**
   ```bash
   cp Birdie/Secrets.plist.example Birdie/Secrets.plist
   ```
   Replace `YOUR_OPENCAGE_API_KEY` with your key from [opencagedata.com](https://opencagedata.com).

4. **Open in Xcode**
   ```bash
   open Birdie.xcodeproj
   ```
   Swift Package Manager will resolve dependencies automatically.

5. **Build and run** on a simulator or device.

> `Secrets.plist` and `GoogleService-Info.plist` are listed in `.gitignore` and will never be committed.

## Project structure

```
Birdie/
├── BirdieApp.swift          # App entry point, dependency wiring
├── Contracts/               # Protocols for services and repositories
├── Controllers/             # Business logic (Auth, BirdSpot, Location, User)
├── Models/                  # Data models (BirdSpot, BirdSpecies, etc.)
├── Services/                # Firebase, Auth, Location, and seeder services
└── Views/
    ├── Auth/                # Login and registration screens
    ├── BirdSpot/            # Sighting list, map, detail, add, filter views
    ├── Misc/                # Root view, splash, empty state, user image
    └── Profile/             # Profile and edit profile views
```
