//
//  DogProfile.swift
//  dogtraffic
//
//  Created by Balaji on 6/8/25.
//
import Foundation
import SwiftUI

struct DogProfile: Identifiable, Codable, Hashable {
    var id = UUID().uuidString
    var name: String
    var breed: String
    var age: Int?
    var photoURL: String? // NEW: The dog's profile picture URL
}
