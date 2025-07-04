//
//  GiniCaptureUserDefaultPropertyWrapper.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

/**
 This is for internal use only.
 This is a property wrapper for managing UserDefaults storage. It allows for easy encoding and decoding of Codable types.
 */

@propertyWrapper
public struct GiniCaptureUserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            // Handle Codable types with JSON encoding/decoding
            if let data = UserDefaults.standard.data(forKey: key),
               let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
                return decodedValue
            }
            return defaultValue
        }
        set {
            // Handle Codable types with JSON encoding
            if let encodedValue = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedValue, forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}
