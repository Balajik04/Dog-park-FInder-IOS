//
//  APIKeyManager.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//

import Foundation

enum APIKeyManager {
    static func getPlacesAPIKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("[APIKeyManager] ERROR: Couldn't find file 'Secrets.plist'.")
        }
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("[APIKeyManager] ERROR: Could not read 'Secrets.plist'.")
        }
        guard let value = plist.object(forKey: "PLACES_API_KEY") as? String else {
            fatalError("[APIKeyManager] ERROR: Couldn't find key 'PLACES_API_KEY' in 'Secrets.plist'.")
        }
        if value.starts(with: "YOUR_") || value.isEmpty {
             fatalError("[APIKeyManager] ERROR: API key in 'Secrets.plist' is a placeholder or empty.")
        }
        if value.hasPrefix("Optional(\"") && value.hasSuffix("\")") {
            let startIndex = value.index(value.startIndex, offsetBy: "Optional(\"".count)
            let endIndex = value.index(value.endIndex, offsetBy: -"\")".count)
            let extractedKey = String(value[startIndex..<endIndex])
            print("[APIKeyManager] WARNING: API key in 'Secrets.plist' appears wrapped. Using extracted key: \(extractedKey)")
            return extractedKey
        }
        print("[APIKeyManager] Successfully loaded API Key.")
        return value
    }
}
