//
//  EditDogView.swift
//  dogtraffic
//
//  Created by Balaji on 6/9/25.
//

import SwiftUI

struct EditDogView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Use @State to hold editable copies of the dog's properties
    @State private var dogName: String
    @State private var selectedBreed: String
    
    // The original dog profile being edited
    private let dog: DogProfile
    
    @State private var showingDeleteConfirmation = false
    
    init(dog: DogProfile) {
        self.dog = dog
        _dogName = State(initialValue: dog.name)
        _selectedBreed = State(initialValue: dog.breed)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Dog Details")) {
                    TextField("Dog's Name", text: $dogName)
                    // In a real app, you would load the breed list here too
                    TextField("Breed", text: $selectedBreed)
                }
                
                Section {
                    Button("Save Changes") {
                        // Create an updated DogProfile object
                        var updatedDog = dog
                        updatedDog.name = dogName
                        updatedDog.breed = selectedBreed
                        
                        authViewModel.updateDogProfile(updatedDog)
                        dismiss()
                    }
                    .disabled(dogName.isEmpty)
                }
                
                Section {
                    Button("Delete Dog", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit \(dog.name)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Are you sure?", isPresented: $showingDeleteConfirmation) {
                Button("Delete Dog", role: .destructive) {
                    authViewModel.deleteDogProfile(dog)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently remove \(dog.name) from your profile.")
            }
        }
    }
}
