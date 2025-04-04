import SwiftUI

struct HomeView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var targetPace: String = ""
    @State private var navigateToRun = false
    @State private var navigationPath = NavigationPath()
    @State private var navigateToSimulatedRun = false
    @State private var navigateToLiveRun = false
    
    let customBlue = Color(red: 90/255, green: 191/255, blue: 211/255)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 30) {
                Text("👟 Tempo Run")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top)
                
                Text("Start a playlist in the Spotify app.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // 🎶 Now Playing Card
                VStack(spacing: 10) {
                    Text("🎶 Now Playing")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(spotifyManager.currentSong.isEmpty ? "Waiting for playback..." : spotifyManager.currentSong)
                        .font(.body)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.9))
                .cornerRadius(16)
                .shadow(radius: 6)
                .padding(.horizontal)
                
                // 🎯 Target Pace Input
                if !spotifyManager.currentSong.isEmpty {
                    VStack(spacing: 15) {
                        Text("🎯 Target Pace (min/km)")
                            .font(.headline)
                        
                        TextField("e.g. 5.00", text: $targetPace)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                            .multilineTextAlignment(.center)
                        
                        if !targetPace.isEmpty {
                            VStack(spacing: 20) {
                                Button(action: {
                                    navigateToSimulatedRun = true
                                }) {
                                    Text("🕹️ Simulated Run")
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    navigateToLiveRun = true
                                }) {
                                    Text("📍 Live Run")
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(radius: 6)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.bottom)
            .navigationDestination(isPresented: $navigateToSimulatedRun) {
                RunView(targetPace: targetPace)
            }
            .navigationDestination(isPresented: $navigateToLiveRun) {
                LiveRunView(targetPace: targetPace)
            }
        }
        .preferredColorScheme(.light)
    }
}
