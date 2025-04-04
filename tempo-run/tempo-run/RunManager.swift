import Foundation
import CoreLocation
import Combine

class RunManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentPace: Double = 0 // min/km

    private var timer: Timer?
    private var startTime: Date?
    private var distance: CLLocationDistance = 0
    private var lastLocation: CLLocation?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func startRun() {
        distance = 0
        startTime = Date()
        elapsedTime = 0
        lastLocation = nil
        locationManager.startUpdatingLocation()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let start = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }

    func stopRun() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Location Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy < 20 else { return }

        if let last = lastLocation {
            let segmentDistance = newLocation.distance(from: last)
            distance += segmentDistance

            if elapsedTime > 0 {
                let paceInSecondsPerKm = elapsedTime / (distance / 1000)
                self.currentPace = paceInSecondsPerKm / 60 // convert to min/km
            }
        }

        lastLocation = newLocation
    }
}

