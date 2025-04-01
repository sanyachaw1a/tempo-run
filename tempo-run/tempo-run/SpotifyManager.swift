import Foundation
import Combine
import AuthenticationServices
import UIKit

class SpotifyManager: NSObject, ObservableObject {
    @Published var currentSong: String = "No song playing"
    @Published var accessToken: String? = nil
    @Published var currentTrackId: String? = nil
    
    private var timer: AnyCancellable?
    
    // Spotify credentials (for demonstration; secure these in production)
    private let clientId = "30641608d7824a12b808944755f0dbe2"
    private let clientSecret = "246191abe275412eb48204fa7b97586d"
    // Callback URL as registered in Info.plist
    private let redirectUri = "https://sportify.sanyachawla.com/callback.php?platform=spotify"
    
    // MARK: - Login and Authentication
    
    func login() {
        let scopes = "user-read-currently-playing user-read-playback-state"
        let redirectEncoded = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let scopesEncoded = scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let authURLString = "https://accounts.spotify.com/authorize?client_id=\(clientId)&response_type=code&redirect_uri=\(redirectEncoded)&scope=\(scopesEncoded)"
        
        guard let authURL = URL(string: authURLString) else {
            print("Invalid auth URL")
            return
        }
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "sportify") { callbackURL, error in
            if let error = error {
                print("Authentication error: \(error.localizedDescription)")
                return
            }
            if let callbackURL = callbackURL,
               let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
               let code = queryItems.first(where: { $0.name == "code" })?.value {
                print("Received code: \(code)")
                self.exchangeCodeForToken(code: code)
            }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    func exchangeCodeForToken(code: String) {
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri,
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }
                                   .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error exchanging code: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data in token response.")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    DispatchQueue.main.async {
                        self.accessToken = token
                        self.startPolling()
                    }
                }
            } catch {
                print("Error parsing token response: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Polling for Current Song
    
    func startPolling() {
        timer?.cancel()
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchCurrentSong()
            }
    }
    
    func fetchCurrentSong() {
        guard let token = accessToken else {
            print("No access token available")
            return
        }
        let url = URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching current song: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received for current song.")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let item = json["item"] as? [String: Any],
                   let name = item["name"] as? String,
                   let trackId = item["id"] as? String,
                   let artists = item["artists"] as? [[String: Any]],
                   let firstArtist = artists.first,
                   let artistName = firstArtist["name"] as? String {
                    
                    let songTitle = "\(name) - \(artistName)"
                    DispatchQueue.main.async {
                        self.currentSong = songTitle
                        self.currentTrackId = trackId
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentSong = "No song playing"
                        self.currentTrackId = nil
                    }
                }
            } catch {
                print("Error parsing current song response: \(error)")
            }
        }.resume()
    }
    
    /// Sends a command to Spotify to play the specified track immediately.
    func playSong(with trackId: String) {
        guard let token = accessToken else {
            print("No access token for playing song")
            return
        }
        guard let url = URL(string: "https://api.spotify.com/v1/me/player/play") else {
            print("Invalid play URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "uris": ["spotify:track:\(trackId)"]
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding play song body: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error playing song: \(error)")
            } else {
                print("Song play command sent successfully")
            }
        }.resume()
    }
}

extension SpotifyManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

