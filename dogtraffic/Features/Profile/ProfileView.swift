//
//  ProfileView.swift
//  dogtraffic
//
//  Created by Balaji on 6/7/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAddDogSheet = false
    @State private var dogToEdit: DogProfile?

    var body: some View {
        List {
            // Main Profile Picture Section
            Section {
                VStack {
                    if let photoURLString = authViewModel.userProfile?.photoURL, let url = URL(string: photoURLString) {
                        AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                        placeholder: { ProgressView() }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    
                    Text(authViewModel.userProfile?.displayName ?? "No Name Set")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            // Owner Info Section
            Section(header: Text("Owner Info")) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray).frame(width: 25, alignment: .center)
                    Text(authViewModel.userProfile?.displayName ?? "No Name Set")
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray).frame(width: 25, alignment: .center)
                    Text(authViewModel.user?.email ?? "No Email")
                }
            }
            
            // My Dogs Section
            Section(header: Text("My Dogs")) {
                if let dogs = authViewModel.userProfile?.dogProfiles, !dogs.isEmpty {
                    ForEach(dogs) { dog in
                        dogInfoCard(dog: dog)
                    }
                } else {
                    Text("No dogs added yet.")
                }
                
                Button(action: { showAddDogSheet = true }) {
                    Label("Add a New Dog", systemImage: "plus")
                        .foregroundColor(AppColors.parkGreen)
                }
            }
            
            Section(header: Text("⭐ Favorite Parks")) {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.favoriteParks.isEmpty {
                    Text("No favorite parks yet. Tap the star on a park's detail page to add one!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.favoriteParks) { park in
                        // NavigationLink now correctly points to a ParkDetailView
                        NavigationLink(destination: ParkDetailView(park: park)) {
                            VStack(alignment: .leading) {
                                Text(park.name).fontWeight(.semibold)
                                Text(park.address ?? "No address").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Sign Out Section
            Section {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .onAppear {
            // When the view appears, fetch the details for the favorite parks
            if let favIDs = authViewModel.userProfile?.favoriteParkIDs {
                viewModel.fetchFavoriteParks(ids: favIDs)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddDogSheet) { AddDogView() }
        .sheet(item: $dogToEdit) { dog in
            EditDogView(dog: dog)
        }
    }
    
    // NEW: Extracted view for a single dog card
    @ViewBuilder
    private func dogInfoCard(dog: DogProfile) -> some View {
        VStack(spacing: 16) {
            if let photoURLString = dog.photoURL, let url = URL(string: photoURLString) {
                AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                    placeholder: { ProgressView() }
                    .frame(width: 100, height: 100).clipShape(Circle())
            } else {
                Image(systemName: "pawprint.circle.fill")
                    .font(.system(size: 100)).foregroundColor(.gray.opacity(0.3))
            }
            
            Text(dog.name).font(.title3).fontWeight(.bold)
            
            VStack(alignment: .leading) {
                Text("Breed").font(.caption).foregroundColor(.gray)
                Text(dog.breed).frame(maxWidth: .infinity, alignment: .leading).padding()
                    .background(AppColors.appBackground).cornerRadius(10)
            }
            
            // NEW: Action buttons for each dog
            HStack {
                Button(action: { dogToEdit = dog }) {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(action: {
                    authViewModel.setMainProfilePicture(from: dog)
                }) {
                    Label("Set as Avatar", systemImage: "person.crop.circle.badge.checkmark")
                }
                .buttonStyle(.bordered)
                .tint(AppColors.parkGreen)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthViewModel()) // Inject dummy VM for preview
        }
    }
}
