//
//  AppLock.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 11/11/2026.
//

import Foundation

// MARK: - AppLock

final class AppLock {

    static let shared = AppLock()

    enum Status {
        case unlocked
        case locked
        case needsPasscode
    }

    enum UnlockResult {
        case success
        case wrong(triesLeft: Int)
        case lockedOut(seconds: Int)
    }

    static let passcodeLength = 6
    static let relockAfter: TimeInterval = 60
    static let maxTries = 5
    static let lockoutSeconds: TimeInterval = 30

    var onChange: ((Status) -> Void)?

    private(set) var status: Status = .unlocked {
        didSet { onChange?(status) }
    }

    private var wentToBackgroundAt: Date?
    private var wrongTries = 0
    private var lockedOutUntil: Date?

    private init() {}

    // MARK: - When to lock

    func appLaunchedSignedIn() {
        status = PasscodeStore.hasPasscode ? .locked : .needsPasscode
    }

    func userSignedIn() {
        status = PasscodeStore.hasPasscode ? .unlocked : .needsPasscode
    }

    func appDidEnterBackground() {
        wentToBackgroundAt = Date()
    }

    func appWillEnterForeground() {
        guard status == .unlocked, PasscodeStore.hasPasscode, let since = wentToBackgroundAt else { return }
        if Date().timeIntervalSince(since) >= Self.relockAfter {
            status = .locked
        }
    }

    // MARK: - Passcode

    func createPasscode(_ passcode: String) {
        PasscodeStore.save(passcode)
        wrongTries = 0
        status = .unlocked
    }

    var lockoutSecondsLeft: Int {
        guard let until = lockedOutUntil else { return 0 }
        return max(0, Int(until.timeIntervalSinceNow.rounded(.up)))
    }

    func unlock(with passcode: String) -> UnlockResult {
        let result = check(passcode)
        if case .success = result { status = .unlocked }
        return result
    }

    func changePasscode(to newPasscode: String) {
        PasscodeStore.save(newPasscode)
    }

    func check(_ passcode: String) -> UnlockResult {
        if lockoutSecondsLeft > 0 {
            return .lockedOut(seconds: lockoutSecondsLeft)
        }
        if lockedOutUntil != nil {
            lockedOutUntil = nil
            wrongTries = 0
        }

        if PasscodeStore.matches(passcode) {
            wrongTries = 0
            return .success
        }

        wrongTries += 1
        if wrongTries >= Self.maxTries {
            lockedOutUntil = Date().addingTimeInterval(Self.lockoutSeconds)
            return .lockedOut(seconds: Int(Self.lockoutSeconds))
        }
        return .wrong(triesLeft: Self.maxTries - wrongTries)
    }

    // MARK: - Sign out

    func reset() {
        PasscodeStore.delete()
        wrongTries = 0
        lockedOutUntil = nil
        wentToBackgroundAt = nil
        status = .unlocked
    }
}
