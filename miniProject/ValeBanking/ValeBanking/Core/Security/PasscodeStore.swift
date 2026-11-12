//
//  PasscodeStore.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 11/11/2026.
//

import Foundation
import CryptoKit

// MARK: - PasscodeStore

enum PasscodeStore {

    private static let key = "vale.passcode"

    static var hasPasscode: Bool {
        KeychainStore.read(key) != nil
    }

    static func save(_ passcode: String) {
        let salt = UUID().uuidString                       
        KeychainStore.save("\(salt):\(hash(passcode, salt: salt))", for: key)
    }

    static func matches(_ passcode: String) -> Bool {
        guard let stored = KeychainStore.read(key) else { return false }
        let parts = stored.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return false }
        return hash(passcode, salt: parts[0]) == parts[1]
    }

    static func delete() {
        KeychainStore.delete(key)
    }

    private static func hash(_ passcode: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + passcode).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
