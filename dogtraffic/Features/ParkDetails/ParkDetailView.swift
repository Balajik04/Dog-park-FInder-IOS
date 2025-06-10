//
//  ParkDetailView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import MapKit

struct ParkDetailView: View {
    // MODIFICATION: Removed the incorrect @ObservedObject property.
    // This is now the ONLY viewModel property.
    @StateObject private var viewModel: ParkDetailViewModel
    
    // This is needed to check favorite status and get user info for check-ins.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // This state is local to this view for the dog count picker.
    @State private var dogCountForCheckIn = 1

    // The initializer now correctly creates the single StateObject.
    init(park: DogPark) {
        _viewModel = StateObject(wrappedValue: ParkDetailViewModel(park: park))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                parkImage
                
                parkHeader
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                checkInSection
                    .padding(.horizontal)

                actionButtons
                    .padding(.horizontal)
                
                parkInfoSection
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.park.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    authViewModel.toggleFavorite(parkId: viewModel.park.id)
                }) {
                    Image(systemName: authViewModel.isFavorite(parkId: viewModel.park.id) ? "star.fill" : "star")
                        .foregroundColor(authViewModel.isFavorite(parkId: viewModel.park.id) ? .yellow : .gray)
                }
            }
        }
    }

    // MARK: - Subviews

    private var parkImage: some View {
        AsyncImage(url: URL(string: viewModel.park.imageURL ?? "")) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(AppColors.cardBackground.opacity(0.5))
                    .frame(height: 250)
                    .overlay(ProgressView())
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            case .failure:
                // Add a default placeholder image named "park_placeholder" to your Assets
                Image("park_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var parkHeader: some View {
        Text(viewModel.park.name)
            .font(.largeTitle).fontWeight(.bold)
    }
    
    private var checkInSection: some View {
        SectionBox(title: "Current Traffic") {
            if viewModel.isLoading && viewModel.trafficCount == 0 {
                ProgressView()
            } else {
                HStack {
                    Image(systemName: "pawprint.fill").font(.title2)
                    Text("\(viewModel.trafficCount) Dogs")
                        .font(.title3).fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(AppColors.parkGreen)
                
                Text("Based on user check-ins from the last 2 hours.")
                    .font(.caption).foregroundColor(.secondary)
                
                if !viewModel.currentCheckIns.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Who's Here:").fontWeight(.semibold).padding(.top, 4)
                        ForEach(viewModel.currentCheckIns) { checkIn in
                            Text("- \(checkIn.userDisplayName) (\(checkIn.dogCount) dog\(checkIn.dogCount > 1 ? "s" : ""))")
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if let user = authViewModel.user, let profile = authViewModel.userProfile {
                if viewModel.userIsCheckedIn(userId: user.uid) {
                    Button(action: { viewModel.performCheckOut(for: user.uid) }) {
                        Label("Check Out", systemImage: "figure.walk.departure")
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent).tint(.orange)
                } else {
                    HStack {
                        Button(action: {
                            viewModel.performCheckIn(for: user, displayName: profile.displayName ?? "A dog lover", dogCount: dogCountForCheckIn)
                        }) {
                            Label("Check In", systemImage: "figure.walk.arrival")
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent).tint(AppColors.sunshineYellow)
                        
                        Picker("Dogs", selection: $dogCountForCheckIn) {
                            ForEach(1...10, id: \.self) { count in Text("\(count)").tag(count) }
                        }.pickerStyle(.menu)
                    }
                }
            }

            Button { openMapsForDirections() } label: {
                Label("Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
            }
            .buttonStyle(.bordered).tint(AppColors.skyBlue)
        }
    }
    
    private var parkInfoSection: some View {
        SectionBox(title: "Park Information") {
            InfoRow(label: "Address", value: viewModel.park.address ?? "N/A", icon: "mappin.and.ellipse")
            InfoRow(label: "Hours", value: viewModel.park.operatingHours ?? "N/A", icon: "clock.fill")
            if !viewModel.park.amenities.isEmpty {
                Text("Amenities:").font(.headline).padding(.top, 5)
                ForEach(viewModel.park.amenities, id: \.self) { amenity in
                    Label(amenity, systemImage: "checkmark.circle.fill")
                        .foregroundColor(AppColors.parkGreen).padding(.leading, 5)
                }
            }
        }
    }
    
    private func openMapsForDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.park.coordinate))
        mapItem.name = viewModel.park.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}


// MARK: - Preview Provider (Corrected)
struct ParkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample park to pass to the view for the preview
        let samplePark = MockData.shared.sampleParks[0]
        
        // Create a dummy AuthViewModel for the preview
        let authViewModel = AuthViewModel()
        
        // Simulate a logged-in user for the preview to work correctly
        // In a real app, you might need more sophisticated preview setup
        // For now, this lets the view render.
        
        return NavigationView {
            ParkDetailView(park: samplePark)
                .environmentObject(authViewModel)
        }
    }
}
