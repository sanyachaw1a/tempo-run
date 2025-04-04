# 👟 Tempo Run

An AI-powered iOS app that dynamically adjusts your Spotify queue to help you run faster based on your pace!

## 📜 Overview

Tempo Run connects to your Spotify account, detects your current song, analyzes your running pace, and intelligently queues better songs to help you match your target pace!

### Features:

- 📀 Detects your currently playing playlist and tracks.
- 🏃 Offers Simulated Run (manual pace slider) or Live Run (GPS-based pace tracking).
- 🤖 Uses BPM analysis to dynamically adjust the queue.
- 🛟 Falls back to Groq AI API or web scraping SongBPM.com if BPM info is missing.
- 🔗 Built with Spotify's OAuth authentication, with a secure callback.php redirect.
- 📈 Summarizes your run with pace statistics and songs played.

## 📂 Project Structure

| File/Folder | Purpose |
|-------------|---------|
| HomeView.swift | Main landing page. Choose Simulated Run or Live Run. |
| RunView.swift | Simulated Run mode: adjust your pace manually. |
| LiveRunView.swift | Live Run mode: use GPS tracking for actual running pace. |
| RunSummaryView.swift | After ending a run, see a summary of your songs and average pace. |
| SpotifyManager.swift | Handles all Spotify authentication, playback info fetching, queueing logic, BPM fetching, etc. |
| RunManager.swift | GPS-based tracking of distance and calculation of real pace. |
| Env.swift | Placeholder environment file for API keys and secrets (no sensitive data). |
| callback.php | Lightweight PHP file hosted on server for handling Spotify OAuth redirect. |

## ⚙️ Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/sanyachaw1a/tempo-run.git
```

2. Open the project in Xcode.

3. **Important**: Fill in your own API keys! After cloning, open `Env.swift` and replace placeholders with your actual credentials:
```swift
import Foundation

struct Env {
    static let spotifyClientId = "<YOUR_SPOTIFY_CLIENT_ID>"
    static let spotifyClientSecret = "<YOUR_SPOTIFY_CLIENT_SECRET>"
    static let spotifyRedirectUri = "<YOUR_SPOTIFY_REDIRECT_URI>"
    static let groqApiKey = "<YOUR_GROQ_API_KEY>"
}
```

4. Make sure your Spotify app is configured to redirect to your server's callback.php properly.

5. Build and run on a physical iOS device (location tracking requires real hardware).

## 🌎 External APIs Used

**Spotify Web API**
- 🔹 Authentication (OAuth 2.0)
- 🔹 Playback control, now playing info, queue control.

**Groq AI API** (via custom PHP server)
- 🔹 Used as backup BPM estimation when Spotify lacks audio features.

**SongBPM.com Scraping**
- 🔹 If BPM cannot be found via Spotify or Groq, a simple web scraper fetches from SongBPM.com.

🚀 ✨ Built with love, music, and a lot of running shoes 👟.
