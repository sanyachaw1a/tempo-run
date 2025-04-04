import SwiftUI

struct RunView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var spotifyManager: SpotifyManager
    @StateObject private var runManager = RunManager()

    @State private var lastKnownSong: String = ""
    @State private var fakePace: Double = 5.5
    @State private var playedSongs: [(song: String, pace: Double)] = []
    @State private var navigateToSummary = false
    @State private var isLoading = true

    let targetPace: String

    private let minPace: Double = 3.0
    private let maxPace: Double = 8.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading playlist tracks...")
                } else {
                    VStack(spacing: 10) {
                        Text("🎯 Target Pace: \(targetPace) min/km")
                        Text("⏱ Elapsed: \(formatTime(runManager.elapsedTime))")
                        Text("📏 Current Pace: \(String(format: "%.2f", fakePace)) min/km")

                        Text("🎵 Now Playing:")
                        Text(spotifyManager.currentSong)
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)

                        paceSliderSection
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
                    .environmentObject(spotifyManager)
            }
            .onAppear { loadPlaylist() }
            .onDisappear { runManager.stopRun() }
            .onChange(of: spotifyManager.currentSong) { newSong in
                let trimmedNewSong = newSong.trimmingCharacters(in: .whitespacesAndNewlines)
                if lastKnownSong != trimmedNewSong {
                    lastKnownSong = trimmedNewSong
                    playedSongs.append((song: trimmedNewSong, pace: fakePace))

                    let target = Double(targetPace) ?? 5.0
                    spotifyManager.handleDynamicQueueing(currentPace: fakePace, targetPace: target)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var paceSliderSection: some View {
        VStack(spacing: 10) {
            Text("🏃‍♂️ Adjust Your Pace")
                .font(.headline)

            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let offset = CGFloat((fakePace - minPace) / (maxPace - minPace)) * width
                    Text("🏃‍♂️")
                        .font(.system(size: 30))
                        .offset(x: offset - 15)
                        .animation(.easeInOut(duration: 0.2), value: fakePace)
                }
                .frame(height: 30)
            }
            .padding(.horizontal)

            Slider(value: $fakePace, in: minPace...maxPace, step: 0.1)
                .padding(.horizontal)

            Text("Pace: \(String(format: "%.2f", fakePace)) min/km")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
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
                
                // 🆕 Immediately queue based on the starting song!
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let target = Double(targetPace) ?? 5.0
                    spotifyManager.handleDynamicQueueing(currentPace: fakePace, targetPace: target)
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


