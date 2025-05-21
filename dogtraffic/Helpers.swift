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
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 4)
            content
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String?

    var body: some View {
        HStack(alignment: .top) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(AppColors.skyBlue) // Consistent icon color
                    .frame(width: 20, alignment: .center)
            }
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            Text(value)
                .lineLimit(nil)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}
