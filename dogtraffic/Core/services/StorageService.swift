//
//  StorageService.swift
//  dogtraffic
//
//  Created by Balaji on 6/8/25.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    private let storage = Storage.storage()
    func uploadDogProfileImage(imageData: Data, for userId: String, dogId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Path is now more specific: dog_images/{userId}/{dogId}/profile.jpg
        let storageRef = storage.reference().child("dog_images/\(userId)/\(dogId)/profile.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        guard let image = UIImage(data: imageData),
              let compressedData = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(NSError(domain: "StorageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image."])))
            return
        }
        
        storageRef.putData(compressedData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error)); return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
}
