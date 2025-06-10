//
//  AddDogView.swift
//  dogtraffic
//
//  Created by Balaji on 6/8/25.
//


import SwiftUI
import PhotosUI

struct AddDogView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var dogName: String = ""
    @State private var selectedBreed: String = "Mixed"
    @State private var allBreeds: [String] = ["Mixed"]
    @State private var isLoadingBreeds = true
    
    @State private var showImagePicker = false
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?
    
    private let dogApiService = DogAPIService()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dog's Photo")) {
                    VStack {
                        Button {
                            showImagePicker = true
                        } label: {
                            ZStack {
                                if let image = selectedUIImage {
                                    Image(uiImage: image)
                                        .resizable().scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.system(size: 120))
                                        .foregroundColor(.gray.opacity(0.3))
                                }
                            }
                        }
                        Text("Tap to add a photo")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Dog Details")) {
                    TextField("Dog's Name", text: $dogName)
                    
                    if isLoadingBreeds {
                        HStack { Text("Loading breeds..."); ProgressView() }
                    } else {
                        Picker("Breed", selection: $selectedBreed) {
                            ForEach(allBreeds, id: \.self) { breed in Text(breed).tag(breed) }
                        }
                    }
                }
                
                Section {
                    Button("Add Dog") {
                        let newDog = DogProfile(name: dogName, breed: selectedBreed)
                        authViewModel.addDogProfile(newDog, imageData: selectedImageData)
                        dismiss()
                    }
                    .disabled(dogName.isEmpty)
                }
            }
            .navigationTitle("Add a New Dog")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
            .onAppear(perform: loadBreeds)
            .sheet(isPresented: $showImagePicker) {
                ProfilePhotoPicker(selectedImageData: $selectedImageData)
            }
            .onChange(of: selectedImageData) { _, newData in
                if let data = newData {
                    self.selectedUIImage = UIImage(data: data)
                }
            }
        }
    }
    
    private func loadBreeds() {
        guard isLoadingBreeds else { return }
        
        dogApiService.fetchAllBreeds { result in
            DispatchQueue.main.async {
                // MODIFICATION: Ensure isLoading is set to false even on failure.
                self.isLoadingBreeds = false
                switch result {
                case .success(let breeds):
                    self.allBreeds.append(contentsOf: breeds)
                case .failure(let error):
                    print("Error fetching breeds: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AddDogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddDogView()
        }
    }
}
