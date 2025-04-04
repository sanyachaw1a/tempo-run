import SwiftUI

struct LiveRunView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var spotifyManager: SpotifyManager
    @StateObject private var runManager = RunManager()

    @State private var lastKnownSong: String = ""
    @State private var playedSongs: [(song: String, pace: Double)] = []
    @State private var navigateToSummary = false
    @State private var isLoading = true

    let targetPace: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading playlist tracks...")
                } else {
                    VStack(spacing: 10) {
                        Text("🎯 Target Pace: \(targetPace) min/km")
                        Text("⏱ Elapsed: \(formatTime(runManager.elapsedTime))")
                        Text("📍 Current Pace: \(String(format: "%.2f", runManager.currentPace)) min/km")

                        Text("🎵 Now Playing:")
                        Text(spotifyManager.currentSong)
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 6)
                    .padding()

                    Spacer()

                    Button("End Run") {
                        runManager.stopRun()
                        navigateToSummary = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToSummary) {
                RunSummaryView(playedSongs: playedSongs)
            }
            .onAppear { loadPlaylist() }
            .onDisappear { runManager.stopRun() }
            .onChange(of: spotifyManager.currentSong) { newSong in
                let trimmedNewSong = newSong.trimmingCharacters(in: .whitespacesAndNewlines)
                if lastKnownSong != trimmedNewSong {
                    lastKnownSong = trimmedNewSong
                    playedSongs.append((song: trimmedNewSong, pace: runManager.currentPace))

                    let target = Double(targetPace) ?? 5.0
                    spotifyManager.handleDynamicQueueing(currentPace: runManager.currentPace, targetPace: target)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func loadPlaylist() {
        spotifyManager.fetchCurrentPlaybackInfo { detectedPlaylistId in
            guard let playlistId = detectedPlaylistId else {
                print("❗️ Could not detect playlist.")
                return
            }
            spotifyManager.fetchAllTracksAndFeatures(for: playlistId) {
                isLoading = false
                runManager.startRun()
                spotifyManager.startPollingPlayback()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let target = Double(targetPace) ?? 5.0
                    spotifyManager.handleDynamicQueueing(currentPace: runManager.currentPace, targetPace: target)
                }
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

