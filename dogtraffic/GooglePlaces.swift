//
//  GooglePlaces.swift
//  dogtraffic
//
//  Created by Balaji on 5/16/25.
//

import Foundation
import SwiftUI

struct PlacesResponse: Codable {
    let results: [Place]
    let status: String
    let error_message: String?
}

struct Place: Codable, Identifiable {
    var id: String { place_id }
    let place_id: String
    let name: String
    let vicinity: String?
    let formatted_address: String?
    let geometry: Geometry
    let photos: [PhotoInfo]?
    let opening_hours: PlaceOpeningHours? // For Place Details
    let types: [String]? // To help confirm it's a park
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct PhotoInfo: Codable {
    let photo_reference: String
    // height and width are also available if needed
}

struct PlaceOpeningHours: Codable {
    let weekday_text: [String]?
    // open_now is also available but often needs Place Details call
}
