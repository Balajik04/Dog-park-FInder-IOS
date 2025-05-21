//
//  UserReport.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI

struct UserReport: Identifiable, Hashable {
    let id = UUID()
    let reportedBusyness: BusynessLevel
    let comment: String?
    let timestamp: Date
    let dogsInGroup: Int? // Optional: how many dogs the reporter brought

    // Formatted timestamp for display
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
