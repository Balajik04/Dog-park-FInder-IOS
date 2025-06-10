//
//  ParksListView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//
import SwiftUI
import CoreLocation

struct ParksListView: View {
    @ObservedObject var viewModel: ParkSearchViewModel
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        NavigationView {
            List {
                // The isLoading check should be outside the sections
                if viewModel.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .listRowBackground(Color.clear)
                }
                
                // MODIFICATION: Use the computed properties to show sections.
                // This structure is more stable for SwiftUI Navigation.
                
                // --- FAVORITES SECTION ---
                if !viewModel.favoriteParksForDisplay.isEmpty {
                    Section(header: Text("⭐ Favorite Parks")) {
                        ForEach(viewModel.favoriteParksForDisplay) { park in
                            NavigationLink(destination: ParkDetailView(park: park)) {
                                ParkListRowView(park: park)
                            }
                        }
                    }
                }
                
                // --- NEARBY PARKS SECTION ---
                // Show this section if the filter is "All" and there are nearby parks to display
                if viewModel.currentFilter == .all && !viewModel.nearbyParksForDisplay.isEmpty {
                    Section(header: Text("Nearby Parks")) {
                        ForEach(viewModel.nearbyParksForDisplay) { park in
                            NavigationLink(destination: ParkDetailView(park: park)) {
                                ParkListRowView(park: park)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(AppColors.appBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Dog Park Finder")
            .searchable(text: $viewModel.searchText, prompt: "Search all parks")
            .toolbar {
                toolbarContent
            }
            .overlay(overlayContent)
            .onAppear {
                viewModel.locationManager.requestLocationPermission()
            }
            .onChange(of: isSearching) { _, isNowSearching in
                // MODIFICATION: When search is dismissed (`isNowSearching` becomes false),
                // we reset the ViewModel's search text.
                if !isNowSearching {
                    viewModel.resetSearch()
                }
            }
            // This reacts when the filter is changed by the user.
            .onChange(of: viewModel.currentFilter) { _, _ in
                // This doesn't need to do anything, the computed properties
                // will automatically provide the correct data to the view.
            }
        }
        .accentColor(AppColors.parkGreen)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var overlayContent: some View {
        // Show an empty state only if NOT loading and both lists are empty.
        if !viewModel.isLoading && viewModel.favoriteParksForDisplay.isEmpty && viewModel.nearbyParksForDisplay.isEmpty {
            VStack {
                Image(systemName: "magnifyingglass.circle")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 8)
                
                Text(isSearching ? "No results found." : "No parks found nearby.")
                    .font(.title3).foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center).padding()
            }
        } else if let errorMessage = viewModel.errorMessage {
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50)).foregroundColor(.orange).padding(.bottom, 8)
                Text(errorMessage)
                    .foregroundColor(AppColors.textSecondary).multilineTextAlignment(.center).padding()
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if authViewModel.user != nil {
                NavigationLink(destination: ProfileView()) {
                    if let photoURL = authViewModel.userProfile?.photoURL, let url = URL(string: photoURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                        }
                        .frame(width: 32, height: 32).clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill").font(.title2)
                    }
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Filter", selection: $viewModel.currentFilter) {
                    Text("Show All").tag(ParkListFilter.all)
                    Text("Favorites Only").tag(ParkListFilter.favorites)
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

struct ParksListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy AuthViewModel for the preview
        let authViewModel = AuthViewModel()
        
        // Create the container view which correctly initializes the ParkSearchViewModel
        let containerView = ParksListContainerView(authViewModel: authViewModel)
        
        // Inject the dummy AuthViewModel into the container for the preview
        containerView
            .environmentObject(authViewModel)
    }
}

