//
//  ParkSearchViewModel.swift
//  dogtraffic
//
//  Created by Balaji on 5/18/25.
//
import SwiftUI
import Combine
import MapKit

class ParkSearchViewModel: ObservableObject {
    @Published var parks: [DogPark] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedParkDetails: DogPark?
    @Published var isLocationPermissionDenied = false // NEW: To track permission status

    private let placesService: GooglePlacesService
    private var searchCancellable: AnyCancellable?
    private let searchQuerySubject = PassthroughSubject<String, Never>()
    private var locationManagerCancellable: AnyCancellable? // NEW: For location manager updates

    init(placesService: GooglePlacesService = GooglePlacesService()) {
        self.placesService = placesService
        print("[ParkSearchViewModel] Initialized.")
        setupSearchSubscription()
    }

    private func setupSearchSubscription() {
        print("[ParkSearchViewModel] Setting up search subscription.")
        searchCancellable = searchQuerySubject
            .debounce(for: .milliseconds(750), scheduler: DispatchQueue.main)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty && $0.count > 2 }
            .removeDuplicates()
            .flatMap { [weak self] (query: String) -> AnyPublisher<Result<[DogPark], Error>, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                print("[ParkSearchViewModel] Debounced text search for: '\(query)'")
                self.isLoading = true // Set loading for text search
                self.errorMessage = nil
                return self.textSearchDogParksWithResult(query: query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in self?.handleSearchResult(result, forQuery: "text search") }
    }
    
    private func textSearchDogParksWithResult(query: String) -> AnyPublisher<Result<[DogPark], Error>, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.placesService.searchDogParks(query: query) { result in promise(.success(result)) }
        }.eraseToAnyPublisher()
    }

    // NEW: Fetch nearby dog parks
    func fetchNearbyDogParks(coordinate: CLLocationCoordinate2D) {
        print("[ParkSearchViewModel] fetchNearbyDogParks called for coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        isLoading = true
        errorMessage = nil
        parks = [] // Clear previous results for nearby search

        placesService.searchNearbyDogParks(latitude: coordinate.latitude, longitude: coordinate.longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleSearchResult(result, forQuery: "nearby search")
            }
        }
    }
    
    // NEW: Common handler for search results
    private func handleSearchResult(_ result: Result<[DogPark], Error>, forQuery queryDescription: String) {
        print("[ParkSearchViewModel] Received \(queryDescription) result. Setting isLoading = false.")
        isLoading = false
        switch result {
        case .success(let fetchedParks):
            print("[ParkSearchViewModel] \(queryDescription) success. Fetched \(fetchedParks.count) parks.")
            self.parks = fetchedParks
            if fetchedParks.isEmpty {
                self.errorMessage = "No dog parks found for \(queryDescription). Try a different area or search term."
            } else {
                self.errorMessage = nil
            }
        case .failure(let error):
            print("[ParkSearchViewModel] \(queryDescription) failure: \(error.localizedDescription)")
            self.errorMessage = "\(queryDescription.capitalized) failed: \(error.localizedDescription)"
            self.parks = []
        }
    }

    func performSearch(query: String) {
        print("[ParkSearchViewModel] performSearch (text) called with query: '\(query)'")
        if query.trimmingCharacters(in: .whitespaces).isEmpty || query.count <= 2 {
            print("[ParkSearchViewModel] Query too short or empty. Clearing results.")
            self.parks = []
            self.isLoading = false
            self.errorMessage = query.isEmpty ? nil : "Please enter at least 3 characters to search."
            return
        }
        isLoading = true // Indicate loading as soon as a valid search is initiated
        errorMessage = nil
        searchQuerySubject.send(query)
    }
    
    func fetchDetails(for park: DogPark) {
        print("[ParkSearchViewModel] fetchDetails called for park: '\(park.name)' (ID: \(park.id))")
        isLoading = true; errorMessage = nil
        placesService.fetchPlaceDetails(placeId: park.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let detailedPark):
                    print("[ParkSearchViewModel] Details fetch success for \(detailedPark.name).")
                    if let index = self?.parks.firstIndex(where: { $0.id == detailedPark.id }) {
                        self?.parks[index] = detailedPark
                    }
                    self?.selectedParkDetails = detailedPark
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch details for \(park.name): \(error.localizedDescription)"
                }
            }
        }
    }
    
    // NEW: Listen to LocationManager updates
    func subscribeToLocationUpdates(locationManager: LocationManager) {
        print("[ParkSearchViewModel] Subscribing to location updates.")
        locationManagerCancellable = locationManager.$lastKnownLocation
            .compactMap { $0 } // Ensure location is not nil
            .first() // Only take the first valid location for initial nearby search
            .sink { [weak self] coordinate in
                print("[ParkSearchViewModel] Received initial location for nearby search: \(coordinate)")
                self?.fetchNearbyDogParks(coordinate: coordinate)
            }
        
        // Also monitor status for permission denial
        locationManager.$locationStatus
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    print("[ParkSearchViewModel] Location permission denied or restricted.")
                    self?.isLocationPermissionDenied = true
                    self?.isLoading = false // Stop loading if permission denied
                    self?.errorMessage = "Location access is needed to find nearby parks. Please enable it in Settings."
                } else {
                    self?.isLocationPermissionDenied = false
                }
            }
            .store(in: &cancellables) // Store this subscription too
    }
    private var cancellables = Set<AnyCancellable>() // Store subscriptions
}
