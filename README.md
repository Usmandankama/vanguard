# VanguardNet Mobile (Flutter)
**Mission-Critical P2P Emergency Response Client**

VanguardNet is the mobile interface for a decentralized emergency response network. It focuses on the "Golden Hour" response window, utilizing real-time geospatial data to connect victims with nearby responders in urban Nigerian environments.

## 🚀 Tech Stack
- **Framework:** Flutter (Stable)
- **State Management:** BLoC/Cubit (Predictable state transitions)
- **Geospatial:** Google Maps SDK & Geolocator
- **Real-time:** WebSockets (I/O) for instant SOS broadcasting
- **Local Storage:** Hive (for offline incident caching)

## 🏗️ Architecture: Clean Architecture
The project is divided into three main layers:
1. **Data Layer:** Repository implementations, Data Sources (Remote/Local), and Models (JSON parsing).
2. **Domain Layer:** Entities (Plain classes) and Use Cases (Business rules). **This layer is independent of any external libraries.**
3. **Presentation Layer:** BLoCs/Cubits and UI Widgets.

## 📁 Project Structure
```text
lib/
├── core/                # Global utilities, themes, and network configs
├── features/            # Feature-based modularization
│   ├── auth/            # Identity management
│   ├── sos/             # SOS Trigger & WebSocket handlers
│   └── map/             # PostGIS-integrated proximity view
└── main.dart            # Entry point