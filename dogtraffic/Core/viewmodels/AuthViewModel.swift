//
//  AuthViewModel.swift
//  dogtraffic
//
//  Created by Balaji on 6/7/25.
//


import SwiftUI
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices

@MainActor // Use @MainActor to ensure all updates happen on the main thread
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // For Phone Auth
    @Published var verificationID: String?
    @Published var isShowingVerificationCodeInput = false

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let firestoreService = FirestoreService()
    private let storageService = StorageService()
    
    init() {
        print("[AuthViewModel] Initialized.")
        listenToAuthState()
    }
    
    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func listenToAuthState() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            if let user = user {
                self?.fetchOrCreateUserProfile(for: user)
            } else {
                self?.userProfile = nil
            }
        }
    }

    private func fetchOrCreateUserProfile(for firebaseUser: User) {
        isLoading = true
        firestoreService.fetchUserProfile(userId: firebaseUser.uid) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let profile):
                    if let profile = profile {
                        self?.userProfile = profile
                    } else {
                        let newProfile = UserProfile(
                            id: firebaseUser.uid,
                            email: firebaseUser.email,
                            displayName: firebaseUser.displayName
                        )
                        self?.saveNewUserProfile(newProfile, userId: firebaseUser.uid)
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                }
            }
        }
    }

    private func saveNewUserProfile(_ profile: UserProfile, userId: String) {
        isLoading = true
        firestoreService.saveUserProfile(profile, userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to save new profile: \(error.localizedDescription)"
                } else {
                    self?.userProfile = profile
                }
            }
        }
    }

    // --- Sign-In Methods ---
    
    func signInWithGoogle() async {
        errorMessage = nil; isLoading = true
        defer { isLoading = false }
        
        do {
            guard let presentingVC = await UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else {
                errorMessage = "Could not find presenting view controller."; return
            }
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                errorMessage = "Google Sign-In: ID token missing."; return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: gidSignInResult.user.accessToken.tokenString)
            try await Auth.auth().signIn(with: credential)
        } catch {
            errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
        }
    }
    
    func addDogProfile(_ dog: DogProfile, imageData: Data?) {
        // MODIFICATION: Added a guard to ensure user profile exists before proceeding.
        guard var currentUserProfile = userProfile, let userId = user?.uid else {
            errorMessage = "Could not add dog. User profile not loaded."
            return
        }
        
        var newDog = dog
        
        if let data = imageData {
            isLoading = true
            storageService.uploadDogProfileImage(imageData: data, for: userId, dogId: newDog.id) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        newDog.photoURL = url.absoluteString
                        currentUserProfile.dogProfiles.append(newDog)
                        self.saveUpdatedProfile(currentUserProfile)
                    case .failure(let error):
                        self.isLoading = false
                        self.errorMessage = "Could not upload dog's photo: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            currentUserProfile.dogProfiles.append(newDog)
            saveUpdatedProfile(currentUserProfile)
        }
    }
    
    func updateDogProfile(_ updatedDog: DogProfile) {
        guard var currentUserProfile = userProfile, let _ = user?.uid else { return }
        guard let index = currentUserProfile.dogProfiles.firstIndex(where: { $0.id == updatedDog.id }) else {
            errorMessage = "Could not find dog to update."
            return
        }
        currentUserProfile.dogProfiles[index] = updatedDog
        saveUpdatedProfile(currentUserProfile)
    }
    
    func deleteDogProfile(_ dogToDelete: DogProfile) {
        guard var currentUserProfile = userProfile, let _ = user?.uid else { return }
        currentUserProfile.dogProfiles.removeAll { $0.id == dogToDelete.id }
        // Note: This does not delete the image from Firebase Storage. That would require an additional function.
        saveUpdatedProfile(currentUserProfile)
    }
    
    func setMainProfilePicture(from dog: DogProfile) {
        guard var currentUserProfile = userProfile, let _ = user?.uid else { return }
        // Set the main photoURL to the dog's photoURL. If the dog has no photo, clear it.
        currentUserProfile.photoURL = dog.photoURL
        saveUpdatedProfile(currentUserProfile)
    }
    
    func updateDisplayName(_ newName: String) {
        guard var currentUserProfile = userProfile, let _ = user?.uid else {
            errorMessage = "Cannot update name. User profile not loaded."
            return
        }
        currentUserProfile.displayName = newName
        saveUpdatedProfile(currentUserProfile)
    }
    
    private func saveUpdatedProfile(_ profile: UserProfile) {
        guard let userId = user?.uid else { return }
        isLoading = true
        firestoreService.saveUserProfile(profile, userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error { self?.errorMessage = "Failed to update profile: \(error.localizedDescription)" }
                else { self?.userProfile = profile }
            }
        }
    }
    
    func sendVerificationCode(phoneNumber: String) {
        isLoading = true; errorMessage = nil
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = "Failed to send verification code: \(error.localizedDescription)"
                return
            }
            self?.verificationID = verificationID
            self?.isShowingVerificationCodeInput = true
        }
    }
    
    func verifyCode(verificationCode: String) {
        isLoading = true; errorMessage = nil
        guard let verificationID = verificationID else {
            errorMessage = "Verification ID not found. Please try sending the code again."; isLoading = false; return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        signInWithFirebase(credential: credential)
    }

    private func signInWithFirebase(credential: AuthCredential) {
        isLoading = true
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = "Firebase sign-in failed: \(error.localizedDescription)"
            } else {
                print("[AuthViewModel] Firebase sign-in successful.")
                // Auth state listener handles the rest
            }
        }
    }
    
    func addFavoritePark(parkId: String) {
        guard var profile = userProfile else { return }
        if !profile.favoriteParkIDs.contains(parkId) {
            profile.favoriteParkIDs.append(parkId)
            saveUpdatedProfile(profile)
        }
    }
    
    func removeFavoritePark(parkId: String) {
        guard var profile = userProfile else { return }
        profile.favoriteParkIDs.removeAll { $0 == parkId }
        saveUpdatedProfile(profile)
    }
    
    func toggleFavorite(parkId: String) {
        guard var profile = userProfile else { return }
        
        if profile.favoriteParkIDs.contains(parkId) {
            profile.favoriteParkIDs.removeAll { $0 == parkId }
        } else {
            profile.favoriteParkIDs.append(parkId)
        }
        
        // Optimistically update the local state for immediate UI feedback
        self.userProfile = profile
        // Then save to Firestore
        saveUpdatedProfile(profile)
    }
    
    func isFavorite(parkId: String) -> Bool {
        return userProfile?.favoriteParkIDs.contains(parkId) ?? false
    }

    func signOut() {
        do { try Auth.auth().signOut(); GIDSignIn.sharedInstance.signOut() }
        catch let error { errorMessage = "Error signing out: \(error.localizedDescription)" }
    }
}
