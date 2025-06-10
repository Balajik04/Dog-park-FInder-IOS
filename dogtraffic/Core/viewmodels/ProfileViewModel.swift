//
//  ProfileViewModel.swift
//  dogtraffic
//
//  Created by Balaji on 6/10/25.
//


import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var favoriteParks: [DogPark] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let placesService = GooglePlacesService()
    private var cancellables = Set<AnyCancellable>()
    
    // This ViewModel can be initialized without parameters.
    init() {}
    
    // It takes the list of favorite IDs as a parameter to fetch details.
    func fetchFavoriteParks(ids: [String]) {
        guard !ids.isEmpty else {
            self.favoriteParks = [] // Clear list if there are no favorites
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
                self.favoriteParks = parks.sorted(by: { $0.name < $1.name }) // Sort alphabetically
            }
            .store(in: &cancellables)
    }
}
