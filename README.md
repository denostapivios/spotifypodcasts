# 🎧 Spotify Podcast App

An iOS application for browsing, listening to, and saving podcasts using the Spotify API. Built with SwiftUI and structured using MVVM-C (Model-View-ViewModel-Coordinator) architecture. The project implements Dependency Injection (DI) to ensure a modular, testable, and scalable codebase, featuring caching, pagination, and audio playback.

<br/>

### 🧩 Technologies

- **SwiftUI** – Apple’s modern UI framework  
- **SwiftData** – for local podcast caching  
- **AVKit** – used for audio playback  
- **Spotify API** – source of podcast data (via RapidAPI)
- **URLSession** – for performing asynchronous network requests
- **JSONDecoder** – decodes Spotify API responses into Swift models
- **MVVM + Coordinator** – clean architecture pattern
- **Dependency Injection** - to ensure a modular, testable, and scalable codebase
- **Pagination & Caching** – efficient data loading and storage

<br/>

### 📱 Features

- 🔍 Podcast search  
- 🏠 Home feed with recent episodes   
- 💾 Local caching with background updates  
- ▶️ Audio preview playback  
- 🔁 Pagination support 
- 🌙 Dark mode support via `@AppStorage`
- 🧮 Sorting

<br/>

### 📌 Things to improve

- [ ] Develop a custom audio player with extended UI and playback controls   
- [ ] Favorites list with pagination and pull-to-refresh support  
- [ ] Implement login screen using Firebase Authentication  

