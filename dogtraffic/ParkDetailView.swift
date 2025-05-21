//
//  ParkDetailView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import MapKit

struct ParkDetailView: View {
    @State var park: DogPark
    @ObservedObject var viewModel: ParkSearchViewModel

    @State private var showingReportSheet = false

    private var imageURLForAsyncImage: URL? {
        if let urlString = park.imageURL {
            return URL(string: urlString)
        }
        return nil
    }
    
    @ViewBuilder
       private func asyncImageContent(for phase: AsyncImagePhase) -> some View {
           switch phase {
           case .empty:
               emptyImageView
           case .success(let image):
               successImageView(image: image)
           case .failure:
               failureImageView
           @unknown default:
               EmptyView()
           }
       }
    
    private var emptyImageView: some View {
        Rectangle()
            .fill(AppColors.cardBackground.opacity(0.5))
            .frame(height: 250)
            .overlay(
                park.imageURL != nil ? AnyView(ProgressView()) : AnyView(
                    Image(systemName: "pawprint.fill")
                        .font(.system(size:80))
                        .foregroundColor(AppColors.parkGreen.opacity(0.3))
                )
            )
    }
    
    private func successImageView(image: Image) -> some View {
        image.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 250)
            .clipped()
    }
    
    private var failureImageView: some View {
        Rectangle()
            .fill(AppColors.cardBackground.opacity(0.5))
            .frame(height: 250)
            .overlay(
                VStack {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.largeTitle)
                    Text("Image not available")
                }
                    .foregroundColor(AppColors.textSecondary)
            )
    }
    
    @ViewBuilder
      private var latestReportStatusView: some View {
          if let latestReport = park.userReports.first {
              Text("Last report: \(latestReport.formattedTimestamp)")
                  .font(.caption)
                  .foregroundColor(AppColors.textSecondary)
          } else {
              Text("No user reports yet for busyness.")
                  .font(.caption)
                  .foregroundColor(AppColors.textSecondary)
          }
      }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: imageURLForAsyncImage, content: asyncImageContent)
                
                Text(park.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if park.operatingHours == "Tap to fetch hours" && viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Fetching details...")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal)
                }
                
                SectionBox(title: "Current Conditions") {
                    HStack {
                        Image(systemName: park.currentBusyness.icon).font(.title2)
                        Text(park.currentBusyness.rawValue).font(.title3).fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(park.currentBusyness.color)
                    
                    // MODIFICATION: Using the extracted view
                    latestReportStatusView
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button { showingReportSheet = true } label: {
                        Label("Report", systemImage: "plus.message.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.sunshineYellow)
                    
                    Button { openMapsForDirections() } label: {
                        Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppColors.skyBlue)
                }
                .padding(.horizontal)
                
                SectionBox(title: "Park Information") {
                    InfoRow(label: "Address", value: park.address ?? "N/A", icon: "mappin.and.ellipse")
                    InfoRow(label: "Hours", value: park.operatingHours ?? "Fetching...", icon: "clock.fill")
                    if !park.amenities.isEmpty {
                        Text("Amenities:")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 5)
                        ForEach(park.amenities, id: \.self) { amenity in
                            Label(amenity, systemImage: "checkmark.circle.fill")
                                .foregroundColor(AppColors.parkGreen)
                                .padding(.leading, 5)
                        }
                    } else if !(park.operatingHours == "Tap to fetch hours" && viewModel.isLoading) {
                        Text("Amenities: Not available or tap hours to fetch details.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal)
                
                if !park.userReports.isEmpty {
                    SectionBox(title: "Recent User Reports") {
                        ForEach(park.userReports.prefix(3)) { report in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: report.reportedBusyness.icon).foregroundColor(report.reportedBusyness.color)
                                    Text(report.reportedBusyness.rawValue).fontWeight(.semibold).foregroundColor(AppColors.textPrimary)
                                }
                                if let comment = report.comment, !comment.isEmpty {
                                    Text("\"\(comment)\"").font(.footnote).italic().foregroundColor(AppColors.textSecondary)
                                }
                                Text(report.formattedTimestamp).font(.caption2).foregroundColor(AppColors.textSecondary.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            if report.id != park.userReports.prefix(3).last?.id { Divider() }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .background(AppColors.appBackground)
        .navigationTitle(park.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReportSheet) { ReportBusynessView(park: park).accentColor(AppColors.parkGreen) }
        .onAppear {
            if park.operatingHours == "Tap to fetch hours" || park.operatingHours == "Fetching..." || park.operatingHours == "Hours not available" {
                 viewModel.fetchDetails(for: park)
            }
        }
        // MODIFICATION: Updated onChange to modern syntax (oldValue, newValue)
        .onChange(of: viewModel.selectedParkDetails) { oldValue, newValue in
            if let updatedDetails = newValue, updatedDetails.id == self.park.id {
                self.park = updatedDetails
            }
        }
    }

    private func openMapsForDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: park.coordinate))
        mapItem.name = park.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct ParkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = ParkSearchViewModel()
        let samplePark = MockData.shared.sampleParks[0]
        
        var detailedSamplePark = samplePark
        detailedSamplePark.operatingHours = "9:00 AM - 7:00 PM (Mon-Fri)\n10:00 AM - 6:00 PM (Sat-Sun)"
        detailedSamplePark.amenities = ["Fenced", "Water Fountain", "Agility Course", "Benches"]

        return NavigationView {
            ParkDetailView(park: detailedSamplePark, viewModel: mockViewModel)
        }
    }
}
