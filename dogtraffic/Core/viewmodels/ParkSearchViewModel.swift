//
//  ParkSearchViewModel.swift
//  dogtraffic
//
//  Created by Balaji on 5/18/25.
//
import SwiftUI
import Combine
import MapKit
import CoreLocation

enum ParkListFilter {
    case all, favorites
}

@MainActor
class ParkSearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var nearbyParks: [DogPark] = []
    @Published var favoriteParks: [DogPark] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentFilter: ParkListFilter = .all
    @Published var searchText: String = ""
    
    @Published var locationManager = LocationManager()

    // MARK: - Private Properties
    
    private let placesService = GooglePlacesService()
    private var cancellables = Set<AnyCancellable>()

    init(authViewModel: AuthViewModel) {
        print("[ParkSearchViewModel] Initialized.")
        
        // Subscribe to location updates from the internal locationManager instance.
        locationManager.$lastKnownLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] coordinate in
                self?.fetchNearbyParks(coordinate: coordinate)
            }
            .store(in: &cancellables)
            
        // Subscribe to profile updates to automatically refresh favorites.
        authViewModel.$userProfile
            .compactMap { $0?.favoriteParkIDs }
            .removeDuplicates()
            .sink { [weak self] favoriteIDs in
                self?.fetchFavoriteParks(ids: favoriteIDs)
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties for UI
    
    var favoriteParksForDisplay: [DogPark] {
        if !searchText.isEmpty {
            return favoriteParks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return favoriteParks
    }

    var nearbyParksForDisplay: [DogPark] {
        // Exclude favorites from the "Nearby" list to avoid duplication when showing "All"
        let favoriteIDs = Set(favoriteParks.map(\.id))
        let nearbyOnly = nearbyParks.filter { !favoriteIDs.contains($0.id) }
        
        if !searchText.isEmpty {
            return nearbyOnly.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return nearbyOnly
    }
    
    // MARK: - Fetching Logic
    
    func fetchNearbyParks(coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        placesService.searchNearbyDogParks(latitude: coordinate.latitude, longitude: coordinate.longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let parks):
                    self?.nearbyParks = parks
                case .failure(let error):
                    self?.errorMessage = "Could not fetch nearby parks: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchFavoriteParks(ids: [String]) {
        guard !ids.isEmpty else {
            self.favoriteParks = []
            return
        }
        
        isLoading = true
        let publishers = ids.map { placesService.fetchParkDetailsPublisher(placeId: $0) }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Could not fetch all favorites: \(error.localizedDescription)"
                }
            } receiveValue: { parks in
                self.favoriteParks = parks
            }
            .store(in: &cancellables)
    }

    // --- Search Logic ---
    
    func performTextSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        placesService.searchDogParks(query: searchText) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let parks):
                    let favoriteIDs = self?.favoriteParks.map(\.id) ?? []
                    self?.favoriteParks = parks.filter { favoriteIDs.contains($0.id) }
                    self?.nearbyParks = parks
                case .failure(let error):
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func resetSearch() {
        // Only reset if we are not currently searching via text
        guard searchText.isEmpty else { return }
        
        print("[ParkSearchViewModel] Resetting search state.")
        // Re-fetching nearby parks is still a good idea to restore the view.
        if let coord = locationManager.lastKnownLocation {
            fetchNearbyParks(coordinate: coord)
        }
    }
}
