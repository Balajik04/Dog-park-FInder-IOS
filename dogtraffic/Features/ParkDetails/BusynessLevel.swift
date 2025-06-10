//
//  BusynessLevel.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import MapKit

enum BusynessLevel: String, CaseIterable, Identifiable {
    case empty = "Empty", quiet = "Quiet (1-3 dogs)", moderate = "Moderate (4-7 dogs)", busy = "Busy (8+ dogs)", veryBusy = "Very Busy (12+ dogs)"
    var id: String { self.rawValue }
    var color: Color {
        switch self {
        case .empty: return AppColors.parkGreen
        case .quiet: return .yellow
        case .moderate: return .orange
        case .busy: return .red
        case .veryBusy: return .purple
        }
    }
    var icon: String {
        switch self {
        case .empty: return "figure.walk"
        case .quiet: return "figure.2.arms.open"
        case .moderate: return "person.2.fill"
        case .busy: return "person.3.fill"
        case .veryBusy: return "figure.seated.seatbelt"
        }
    }
}
