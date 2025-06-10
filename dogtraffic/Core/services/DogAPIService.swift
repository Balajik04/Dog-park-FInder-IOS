//
//  DogAPIService.swift
//  dogtraffic
//
//  Created by Balaji on 6/8/25.
//

import Foundation

class DogAPIService {
    struct BreedListResponse: Codable {
        let message: [String: [String]]
        let status: String
    }

    func fetchAllBreeds(completion: @escaping (Result<[String], Error>) -> Void) {
        // MODIFICATION: Corrected the URL from a Markdown link to a valid string.
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else {
            completion(.failure(NSError(domain: "DogAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DogAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let response = try JSONDecoder().decode(BreedListResponse.self, from: data)
                var breedList: [String] = []
                for (mainBreed, subBreeds) in response.message {
                    if subBreeds.isEmpty {
                        breedList.append(mainBreed.capitalized)
                    } else {
                        for subBreed in subBreeds {
                            breedList.append("\(subBreed.capitalized) \(mainBreed.capitalized)")
                        }
                    }
                }
                completion(.success(breedList.sorted()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
