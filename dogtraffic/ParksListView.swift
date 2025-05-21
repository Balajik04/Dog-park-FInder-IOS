//
//  ParksListView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI

struct ParksListView: View {
    @StateObject private var viewModel = ParkSearchViewModel()
    @State private var searchText: String = ""
    @StateObject private var locationManager = LocationManager()
    @State private var didRequestInitialLocation = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if viewModel.isLoading && viewModel.parks.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Searching...").padding()
                            Spacer()
                        }
                        .listRowBackground(AppColors.appBackground)
                    }
                    
                    ForEach(viewModel.parks) { park in
                        NavigationLink(destination: ParkDetailView(park: park, viewModel: viewModel)) {
                            ParkListRowView(park: park)
                        }
                    }
                    
                    if let errorMessage = viewModel.errorMessage, viewModel.parks.isEmpty && !viewModel.isLoading {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(AppColors.appBackground)
                    }
                }
                .listStyle(.plain)
                .background(AppColors.appBackground)
                .overlay {
                     if !viewModel.isLoading && viewModel.errorMessage == nil && searchText.isEmpty && viewModel.parks.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.bottom, 8)
                            Text("Search for dog parks by city or name.")
                                .font(.title3)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    } else if !viewModel.isLoading && viewModel.errorMessage != nil && viewModel.parks.isEmpty {
                         VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                                .padding(.bottom, 8)
                            Text(viewModel.errorMessage ?? "An error occurred.")
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Dog Park Finder")
            .searchable(text: $searchText, prompt: "e.g., 'Chicago Loop' or 'Wicker Park'")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty { // Only perform text search if searchText is not empty
                    viewModel.performSearch(query: newValue)
                } else if didRequestInitialLocation { // If search is cleared, re-fetch nearby if initial location was fetched
                    if let location = locationManager.lastKnownLocation {
                        viewModel.fetchNearbyDogParks(coordinate: location)
                    } else {
                        // Handle case where location is still not available after clearing search
                        viewModel.parks = []
                        viewModel.errorMessage = "Enter a search term or enable location for nearby parks."
                    }
                }
            }
            .onSubmit(of: .search) {
                viewModel.performSearch(query: searchText)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading && !viewModel.parks.isEmpty {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Button { print("Filter tapped (future feature)") } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(AppColors.parkGreen)
                        }
                    }
                }
            }
        }
        .accentColor(AppColors.parkGreen)
        .onAppear {
            print("[ParksListView] onAppear.")
            if !didRequestInitialLocation {
                print("[ParksListView] Requesting initial location.")
                locationManager.requestLocationPermission() // Request permission first
                // Subscription to location updates is now in ViewModel
                viewModel.subscribeToLocationUpdates(locationManager: locationManager)
                didRequestInitialLocation = true
            }
        }
    }
}

struct ParksListView_Previews: PreviewProvider {
    static var previews: some View {
        ParksListView()
        ParksListView()
            .preferredColorScheme(.dark)
    }
}
