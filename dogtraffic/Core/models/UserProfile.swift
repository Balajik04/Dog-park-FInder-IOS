//
//  UserProfile.swift
//  dogtraffic
//
//  Created by Balaji on 6/7/25.
//
import SwiftUI
import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var email: String?
    var displayName: String?
    var photoURL: String?
    var createdAt: Timestamp = Timestamp(date: Date())
    var favoriteParkIDs: [String] = []
    var dogProfiles: [DogProfile] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(id ?? UUID().uuidString)
    }
}
