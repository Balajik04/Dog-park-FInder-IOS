//
//  ParkCheckIn.swift
//  dogtraffic
//
//  Created by Balaji on 6/9/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore

struct ParkCheckIn: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var userDisplayName: String
    var timestamp: Timestamp
    var dogCount: Int
}
