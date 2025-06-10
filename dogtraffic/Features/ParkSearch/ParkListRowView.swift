//
//  ParkListRowView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI

struct ParkListRowView: View {
    let park: DogPark
    var body: some View {
        HStack(spacing: 12) {
            if let imageURLString = park.imageURL, let url = URL(string: imageURLString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if phase.error != nil {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.cardBackground)
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "photo.fill").foregroundColor(AppColors.textSecondary))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.cardBackground)
                            .frame(width: 60, height: 60)
                            .overlay(ProgressView())
                    }
                }
            } else {
                 RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.cardBackground)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(AppColors.parkGreen)
                            .font(.title)
                    )
            }

            VStack(alignment: .leading) {
                Text(park.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text(park.address ?? "Address not available")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ParkListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ParkListRowView(park: MockData.shared.sampleParks[0])
            .previewLayout(.sizeThatFits)
            .padding()
            .background(AppColors.appBackground)
    }
}
