import SwiftUI

struct SplashView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var navigateToNext = false

    let customBlue = Color(red: 90/255, green: 191/255, blue: 211/255)

    var body: some View {
        VStack {
            Spacer(minLength: 150)

            VStack(spacing: -45) {
                Text("TEMPO")
                    .font(.custom("Avenir-MediumOblique", size: 63))
                    .foregroundColor(Color(UIColor.darkGray))
                Text("RUN")
                    .font(.custom("Avenir-BlackOblique", size: 100))
                    .foregroundColor(Color(UIColor.darkGray))
            }
            .padding(.bottom, 5)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [customBlue, Color.white]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 200, height: 200)

                Text("🏃")
                    .font(.system(size: 100))
            }

            Spacer(minLength: 50)

            Button(action: {
                spotifyManager.login()
            }) {
                Text("Connect My Spotify")
                    .foregroundColor(.white)
                    .font(.custom("Avenir-Black", size: 20))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(customBlue)
                    .cornerRadius(20)
                    .padding(.horizontal, 50)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onReceive(spotifyManager.$isLoggedIn) { loggedIn in
            if loggedIn {
                navigateToNext = true
            }
        }
        .fullScreenCover(isPresented: $navigateToNext) {
            HomeView()
                .environmentObject(spotifyManager)
        }
    }
}
