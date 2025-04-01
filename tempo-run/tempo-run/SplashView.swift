import SwiftUI

struct SplashView: View {
    @ObservedObject var spotifyManager = SpotifyManager()
    @State private var navigateToNextStep = false
    @State private var trainingCompleted: Bool? = nil
    let customBlue = Color(red: 90/255, green: 191/255, blue: 211/255)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 150)
                
                // Title: TEMPO (italic) above RUN (bold)
                VStack(spacing: -45) {
                    Text("TEMPO")
                        .font(.custom("Avenir-MediumOblique", size: 63))
                        .foregroundColor(Color(UIColor.darkGray))
                    Text("RUN")
                        .font(.custom("Avenir-BlackOblique", size: 100))
                        .foregroundColor(Color(UIColor.darkGray))
                }
                .padding(.bottom, 5)
                
                // Circle with radial gradient background and a runner emoji inside
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
                    
                    // Runner emoji (adjust size as needed)
                    Text("🏃")
                        .font(.system(size: 100))
                }
                
                Spacer(minLength: 50)
                
                // "Connect My Spotify" button
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
                .padding(.bottom, 20)
                
                // "How It Works" button
                NavigationLink(destination: HowItWorksView()) {
                    Text("How It Works")
                        .foregroundColor(customBlue)
                        .font(.custom("Avenir-Black", size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(customBlue, lineWidth: 3)
                        )
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .onReceive(spotifyManager.$accessToken) { token in
                if token != nil {
                    navigateToNextStep = true
                }
            }
            .background(
                NavigationLink(
                    destination: TrainingView(),
                    isActive: $navigateToNextStep
                ) {
                    EmptyView()
                }
            )
        }
    }
}

struct HowItWorksView: View {
    var body: some View {
        VStack {
            Text("How Tempo Run Works")
                .font(.custom("Avenir-Black", size: 32))
                .padding()
            
            Text("1. Connect your Spotify account.\n2. Complete your first training run.\n3. Our AI dynamically adjusts your Spotify queue to improve your run pace.")
                .font(.custom("Avenir-Medium", size: 20))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct TrainingView: View {
    var body: some View {
        VStack {
            Text("Training Session")
                .font(.custom("Avenir-Black", size: 36))
                .padding()
            
            Text("Complete a minimum 10-minute run")
                .font(.custom("Avenir-Medium", size: 18))
                .padding()
            
            NavigationLink(destination: HomeView()) {
                Text("Finish Training")
                    .foregroundColor(.white)
                    .font(.custom("Avenir-Black", size: 20))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.horizontal, 50)
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home")
                .font(.custom("Avenir-Black", size: 36))
                .padding()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
