//
//  DogPark.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import MapKit

struct DogPark: Identifiable, Hashable {
    let id: String // Use place_id from Google Places
    var name: String
    var address: String?
    var coordinate: CLLocationCoordinate2D
    var imageURL: String?
    var photoReference: String?
    
    var amenities: [String] = [] // Will be populated by Place Details API or user input
    var operatingHours: String? = "Tap to fetch hours" // Placeholder
    var currentBusyness: BusynessLevel = .quiet // Default, updated by user reports
    var userReports: [UserReport] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DogPark, rhs: DogPark) -> Bool {
        lhs.id == rhs.id
    }
}
