//
//  ParkDetailViewModel.swift
//  dogtraffic
//
//  Created by Balaji on 6/9/25.
//


import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ParkDetailViewModel: ObservableObject {
    @Published var park: DogPark
    @Published var currentCheckIns: [ParkCheckIn] = []
    @Published var trafficCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let firestoreService = FirestoreService()
    private var checkInListener: ListenerRegistration?
    
    init(park: DogPark) {
        self.park = park
        listenForCheckIns()
    }
    
    deinit {
        // Stop listening for updates when the view model is deallocated
        checkInListener?.remove()
    }
    
    func listenForCheckIns() {
        isLoading = true
        checkInListener = firestoreService.listenForParkCheckIns(parkId: park.id) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let checkIns):
                // Filter for active check-ins (e.g., within the last 2 hours)
                let twoHoursAgo = Date().addingTimeInterval(-2 * 60 * 60)
                self.currentCheckIns = checkIns.filter { $0.timestamp.dateValue() > twoHoursAgo }
                // Calculate the total number of dogs from active check-ins
                self.trafficCount = self.currentCheckIns.reduce(0) { $0 + $1.dogCount }
            case .failure(let error):
                self.errorMessage = "Failed to get park traffic: \(error.localizedDescription)"
            }
        }
    }
    
    func performCheckIn(for user: User, displayName: String, dogCount: Int) {
        isLoading = true
        firestoreService.checkIn(user: user, parkId: park.id, displayName: displayName, dogCount: dogCount) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = "Check-in failed: \(error.localizedDescription)"
            }
        }
    }
    
    func performCheckOut(for userId: String) {
        isLoading = true
        firestoreService.checkOut(userId: userId, parkId: park.id) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = "Check-out failed: \(error.localizedDescription)"
            }
        }
    }
    
    func userIsCheckedIn(userId: String) -> Bool {
        return currentCheckIns.contains { $0.userId == userId }
    }
}
