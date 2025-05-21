//
//  GooglePlacesService.swift
//  dogtraffic
//
//  Created by Balaji on 5/18/25.
//
import Foundation
import MapKit
import Combine
import SwiftUI
import CoreLocation

class GooglePlacesService {
    private let apiKey = APIKeyManager.getPlacesAPIKey()
    private var session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        print("[GooglePlacesService] Initialized.")
    }

    // Text Search
    func searchDogParks(query: String, completion: @escaping (Result<[DogPark], Error>) -> Void) {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let currentApiKey = self.apiKey
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=dog%20park%20\(formattedQuery)&type=park&key=\(currentApiKey)"
        print("[GooglePlacesService] searchDogParks (Text Search) URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GooglePlacesService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for text search."])))
            return
        }
        performRequest(url: url, requestType: "TextSearch", completion: completion)
    }

    // NEW: Nearby Search
    func searchNearbyDogParks(latitude: Double, longitude: Double, radiusInMeters: Int = 5000, completion: @escaping (Result<[DogPark], Error>) -> Void) {
        let currentApiKey = self.apiKey
        // Using type=park and keyword=dog to find dog parks.
        // You can adjust the radius and keywords.
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radiusInMeters)&type=park&keyword=dog%20park&key=\(currentApiKey)"
        print("[GooglePlacesService] searchNearbyDogParks URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GooglePlacesService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for nearby search."])))
            return
        }
        performRequest(url: url, requestType: "NearbySearch", completion: completion)
    }
    
    func fetchPlaceDetails(placeId: String, completion: @escaping (Result<DogPark, Error>) -> Void) {
        let fields = "place_id,name,formatted_address,vicinity,geometry,photo,opening_hours,type"
        let currentApiKey = self.apiKey
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=\(fields)&key=\(currentApiKey)"
        print("[GooglePlacesService] fetchPlaceDetails URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "GooglePlacesService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for place details."])))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            print("[GooglePlacesService] fetchPlaceDetails dataTask completion entered.")
            if let error = error { print("[GooglePlacesService] fetchPlaceDetails Network Error: \(error.localizedDescription)"); completion(.failure(error)); return }
            if let httpResponse = response as? HTTPURLResponse { print("[GooglePlacesService] fetchPlaceDetails HTTP Status Code: \(httpResponse.statusCode)") }
            guard let data = data else { print("[GooglePlacesService] Error: No data for place details."); completion(.failure(NSError(domain: "GooglePlacesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data for place details."]))); return }
            
            struct PlaceDetailResponse: Codable { let result: Place; let status: String; let error_message: String? }
            do {
                let detailResponse = try JSONDecoder().decode(PlaceDetailResponse.self, from: data)
                print("[GooglePlacesService] fetchPlaceDetails Decoded Status: \(detailResponse.status)")
                if detailResponse.status != "OK" {
                    let errorMessage = detailResponse.error_message ?? "Google Place Details API Error: \(detailResponse.status)"
                    print("[GooglePlacesService] fetchPlaceDetails API Error: \(errorMessage)")
                    completion(.failure(NSError(domain: "GooglePlacesService", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                let park = self.mapPlaceToDogPark(detailResponse.result)
                print("[GooglePlacesService] fetchPlaceDetails Success for \(park.name)")
                completion(.success(park))
            } catch { print("[GooglePlacesService] fetchPlaceDetails JSON Decode Error: \(error)"); completion(.failure(error)) }
        }.resume()
    }

    private func mapPlaceToDogPark(_ place: Place) -> DogPark {
        var imageFullURL: String? = nil
        if let photoRef = place.photos?.first?.photo_reference {
            let currentApiKey = self.apiKey
            imageFullURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=\(photoRef)&key=\(currentApiKey)"
        }
        return DogPark(
            id: place.place_id, name: place.name, address: place.formatted_address ?? place.vicinity,
            coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng),
            imageURL: imageFullURL, photoReference: place.photos?.first?.photo_reference,
            operatingHours: place.opening_hours?.weekday_text?.joined(separator: "\n") ?? "Hours not available"
        )
    }
    
    private func performRequest(url: URL, requestType: String, completion: @escaping (Result<[DogPark], Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            print("[GooglePlacesService] \(requestType) dataTask completion entered.")
            if let error = error { print("[GooglePlacesService] \(requestType) Network Error: \(error.localizedDescription)"); completion(.failure(error)); return }
            if let httpResponse = response as? HTTPURLResponse { print("[GooglePlacesService] \(requestType) HTTP Status Code: \(httpResponse.statusCode)") }
            guard let data = data else { print("[GooglePlacesService] Error: No data for \(requestType)."); completion(.failure(NSError(domain: "GooglePlacesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data for \(requestType)."]))); return }
            
            do {
                let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
                print("[GooglePlacesService] \(requestType) Decoded Status: \(placesResponse.status)")
                if placesResponse.status != "OK" {
                    let errorMessage = placesResponse.error_message ?? "Google Places API Error: \(placesResponse.status)"
                    print("[GooglePlacesService] \(requestType) API Error: \(errorMessage)")
                    completion(.failure(NSError(domain: "GooglePlacesService", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                let dogParks = placesResponse.results.compactMap { place -> DogPark? in
                    let isParkType = place.types?.contains("park") ?? false
                    let nameSuggestsDogPark = place.name.lowercased().contains("dog park") || place.name.lowercased().contains("bark park")
                    if isParkType || nameSuggestsDogPark { return self.mapPlaceToDogPark(place) }
                    return nil
                }
                print("[GooglePlacesService] \(requestType) Success, found \(dogParks.count) relevant parks.")
                completion(.success(dogParks))
            } catch { print("[GooglePlacesService] \(requestType) JSON Decode Error: \(error)"); completion(.failure(error)) }
        }.resume()
    }
}
