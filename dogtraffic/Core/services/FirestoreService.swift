//
//  FirestoreService.swift
//  dogtraffic
//
//  Created by Balaji on 6/7/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    
    // In your production app, you might replace "dogpark-app" with a specific artifact ID
    // or use a global variable provided by the environment, e.g., __app_id.
    private let basePath = "artifacts/dogpark-app/users"
    private let checkInBasePath = "artifacts/dogpark-app/parkCheckIns"

    private func userProfileDocument(userId: String) -> DocumentReference {
        // Path: /artifacts/{appId}/users/{userId}/profile/{userId}
        // Using userId as the document ID for the profile document itself for simplicity.
        return db.collection(basePath).document(userId).collection("profile").document(userId)
    }

    func saveUserProfile(_ userProfile: UserProfile, userId: String, completion: @escaping (Error?) -> Void) {
        let docRef = userProfileDocument(userId: userId)
        print("[FirestoreService] Saving profile for UID: \(userId) to path: \(docRef.path)")
        do {
            var profileToSave = userProfile
            if profileToSave.id == nil { profileToSave.id = userId }
            // Use merge:true to update an existing document or create it if it doesn't exist.
            try docRef.setData(from: profileToSave, merge: true) { error in
                completion(error)
            }
        } catch {
            print("[FirestoreService] Error encoding user profile: \(error.localizedDescription)")
            completion(error)
        }
    }

    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile?, Error>) -> Void) {
        let docRef = userProfileDocument(userId: userId)
        print("[FirestoreService] Fetching profile for UID: \(userId) from path: \(docRef.path)")
        docRef.getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let document = documentSnapshot, document.exists else {
                completion(.success(nil)); return // No profile found is a valid case
            }
            do {
                let userProfile = try document.data(as: UserProfile.self)
                completion(.success(userProfile))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Returns a reference to the sub-collection for a specific park's check-ins
        private func parkCheckInsCollection(parkId: String) -> CollectionReference {
            return db.collection(checkInBasePath).document(parkId).collection("checkedInUsers")
        }
        
    // Check a user into a park
    func checkIn(user: User, parkId: String, displayName: String, dogCount: Int, completion: @escaping (Error?) -> Void) {
        let checkIn = ParkCheckIn(
            userId: user.uid,
            userDisplayName: displayName,
            timestamp: Timestamp(date: Date()),
            dogCount: dogCount
        )
        do {
            // Use the user's UID as the document ID to prevent duplicate check-ins
            try parkCheckInsCollection(parkId: parkId).document(user.uid).setData(from: checkIn, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // Check a user out of a park
    func checkOut(userId: String, parkId: String, completion: @escaping (Error?) -> Void) {
        parkCheckInsCollection(parkId: parkId).document(userId).delete(completion: completion)
    }
    
    // Listen for real-time updates to check-ins for a park
    func listenForParkCheckIns(parkId: String, completion: @escaping (Result<[ParkCheckIn], Error>) -> Void) -> ListenerRegistration {
        return parkCheckInsCollection(parkId: parkId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let checkIns = documents.compactMap { doc -> ParkCheckIn? in
                try? doc.data(as: ParkCheckIn.self)
            }
            completion(.success(checkIns))
        }
    }
}
