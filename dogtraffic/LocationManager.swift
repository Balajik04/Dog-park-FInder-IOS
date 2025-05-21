//
//  LocationManager.swift
//  dogtraffic
//
//  Created by Balaji on 5/20/25.
//
import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var error: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced // Or kCLLocationAccuracyBest for more precision
        print("[LocationManager] Initialized.")
    }

    func requestLocationPermission() {
        print("[LocationManager] Requesting location permission.")
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        print("[LocationManager] Starting location updates.")
        manager.startUpdatingLocation() // For continuous updates
        // Or use manager.requestLocation() for a one-time location fix
    }
    
    func stopUpdatingLocation() {
        print("[LocationManager] Stopping location updates.")
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print("[LocationManager] Authorization status changed: \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation() // Get initial location once authorized
        } else if status == .denied || status == .restricted {
            print("[LocationManager] Location access denied or restricted.")
            // Handle denial (e.g., show an alert to the user to enable in settings)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            lastKnownLocation = location
            print("[LocationManager] Location updated: \(location.latitude), \(location.longitude)")
            // Often, you only need one location update for "nearby" search
            // manager.stopUpdatingLocation() // Uncomment if you only need one-time location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        print("[LocationManager] Failed to get location: \(error.localizedDescription)")
    }
}
