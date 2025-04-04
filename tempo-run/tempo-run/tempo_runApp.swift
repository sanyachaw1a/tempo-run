import SwiftUI
import Firebase

@main
struct TempoRunApp: App {
    @StateObject var spotifyManager = SpotifyManager()


    init() {
        // FirebaseApp.configure() // Remove this line if you're not using Firebase yet
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(spotifyManager)
        }
    }
}

