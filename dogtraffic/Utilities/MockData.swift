//
//  MockData.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import MapKit

class MockData { // Added class wrapper for static let
    static let shared = MockData()

    // Placeholder image URLs - replace with actual URLs or a better placeholder service
    let sampleParks: [DogPark] = [
        DogPark(id: "mock_place_id_1", // ADDED: id field
                name: "Lakeshore East Dog Park",
                address: "450 E Benton Pl, Chicago, IL 60601",
                coordinate: CLLocationCoordinate2D(latitude: 41.8860, longitude: -87.6190),
                imageURL: "https://placehold.co/600x400/A1C181/FFFFFF?text=Lakeshore+East",
                photoReference: "mock_photo_ref_1",
                amenities: ["Fenced", "Water Fountain", "Benches", "Shade"],
                operatingHours: "6:00 AM - 11:00 PM",
                currentBusyness: .moderate,
                userReports: [
                    UserReport(reportedBusyness: .moderate, comment: "A few playful labs here!", timestamp: Date().addingTimeInterval(-300), dogsInGroup: 2),
                    UserReport(reportedBusyness: .quiet, comment: nil, timestamp: Date().addingTimeInterval(-3600), dogsInGroup: 1)
                ]),
        DogPark(id: "mock_place_id_2", // ADDED: id field
                name: "Grant Bark Park",
                address: "1000 S Columbus Dr, Chicago, IL 60605",
                coordinate: CLLocationCoordinate2D(latitude: 41.8711, longitude: -87.6200),
                imageURL: "https://placehold.co/600x400/A2D2FF/000000?text=Grant+Bark+Park",
                photoReference: "mock_photo_ref_2",
                amenities: ["Fenced", "Double-Gated Entry", "Water Spigot", "Agility Equipment (basic)"],
                operatingHours: "4:30 AM - 11:30 PM",
                currentBusyness: .busy,
                userReports: [
                    UserReport(reportedBusyness: .busy, comment: "Weekend rush!", timestamp: Date().addingTimeInterval(-600), dogsInGroup: 1)
                ]),
        DogPark(id: "mock_place_id_3", // ADDED: id field
                name: "Wiggly Field",
                address: "2645 N Sheffield Ave, Chicago, IL 60614",
                coordinate: CLLocationCoordinate2D(latitude: 41.9300, longitude: -87.6530),
                imageURL: "https://placehold.co/600x400/FCCA46/333333?text=Wiggly+Field",
                photoReference: "mock_photo_ref_3",
                amenities: ["Fenced", "Benches", "Gravel Surface"],
                operatingHours: "Sunrise - Sunset",
                currentBusyness: .quiet),
        DogPark(id: "mock_place_id_4", // ADDED: id field
                name: "Montrose Dog Beach",
                address: "Wilson Ave & Lake Shore Dr, Chicago, IL 60640",
                coordinate: CLLocationCoordinate2D(latitude: 41.9660, longitude: -87.6400),
                imageURL: "https://placehold.co/600x400/B08968/FFFFFF?text=Montrose+Beach",
                photoReference: "mock_photo_ref_4",
                amenities: ["Beach Access", "Off-Leash Area", "Water (Lake)"],
                operatingHours: "6:00 AM - 11:00 PM (Seasonal)",
                currentBusyness: .empty)
    ]
}
