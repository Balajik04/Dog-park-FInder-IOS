//
//  Helpers.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI

struct SectionBox<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title2).fontWeight(.semibold).padding(.bottom, 4)
            content
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let label: String, value: String, icon: String?
    var body: some View {
        HStack(alignment: .top) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(AppColors.skyBlue)
                    .frame(width: 25, alignment: .center)
            }
            Text("\(label):")
                .fontWeight(.semibold)
            Text(value)
                .lineLimit(nil)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func uniqued() -> [Iterator.Element] {
        var set = Set<Iterator.Element>()
        return filter { set.insert($0).inserted }
    }
}
