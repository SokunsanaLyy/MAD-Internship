//
//  PasscodeViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 11/11/2026.
//

import Foundation

// MARK: - PasscodeViewModel

final class PasscodeViewModel {

    enum Mode {
        case create
        case unlock
        case change
    }

    enum Step {
        case enterCurrent
        case enterNew
        case confirmNew
        case enter             
    }

    enum State {
        case waiting
        case error(String)
        case lockedOut(seconds: Int)
        case done
    }

    var onChange: ((Step, State) -> Void)?

    let mode: Mode
    private(set) var step: Step
    private(set) var state: State = .waiting

    private let lock = AppLock.shared
    private var firstEntry = ""
    private var countdown: Task<Void, Never>?

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create: step = .enterNew
        case .unlock: step = .enter
        case .change: step = .enterCurrent
        }
    }

    var title: String {
        switch step {
        case .enterCurrent: return "Enter your current passcode"
        case .enterNew: return mode == .change ? "Choose a new passcode" : "Create a passcode"
        case .confirmNew: return mode == .change ? "Confirm your new passcode" : "Confirm your passcode"
        case .enter: return "Enter your passcode"
        }
    }

    var subtitle: String {
        switch step {
        case .enterCurrent: return "To keep your account safe, confirm it's you first."
        case .enterNew: return "You'll use these 6 digits to open Vale instead of signing in each time."
        case .confirmNew: return "Enter the same 6 digits again."
        case .enter: return "Vale is locked to keep your money safe."
        }
    }

    /// Called when all 6 digits are typed.
    func submit(_ code: String) {
        guard code.count == AppLock.passcodeLength else { return }

        switch step {
        case .enterCurrent:
            handle(lock.check(code), onSuccess: { update(.enterNew, .waiting) })

        case .enterNew:
            if let problem = weaknessMessage(for: code) {
                update(.enterNew, .error(problem))
                return
            }
            firstEntry = code
            update(.confirmNew, .waiting)

        case .confirmNew:
            guard code == firstEntry else {
                firstEntry = ""
                update(.enterNew, .error("The passcodes didn't match. Try again."))
                return
            }
            if mode == .change {
                lock.changePasscode(to: code)
            } else {
                lock.createPasscode(code)
            }
            update(.confirmNew, .done)

        case .enter:
            handle(lock.unlock(with: code), onSuccess: { update(.enter, .done) })
        }
    }

    func stopCountdown() {
        countdown?.cancel()
    }

    // MARK: - Private

    private func handle(_ result: AppLock.UnlockResult, onSuccess: () -> Void) {
        switch result {
        case .success:
            onSuccess()
        case .wrong(let triesLeft):
            update(step, .error("Wrong passcode. \(triesLeft) \(triesLeft == 1 ? "try" : "tries") left."))
        case .lockedOut(let seconds):
            startCountdown(from: seconds)
        }
    }

    /// Rejects passcodes that are easy to guess, or the same as the current one.
    private func weaknessMessage(for code: String) -> String? {
        let digits = code.compactMap(\.wholeNumberValue)
        if Set(digits).count == 1 {
            return "Avoid using the same digit six times."
        }
        let steps = zip(digits, digits.dropFirst()).map { $1 - $0 }
        if steps.allSatisfy({ $0 == 1 }) || steps.allSatisfy({ $0 == -1 }) {
            return "Avoid digits in order, like 123456."
        }
        if mode == .change, PasscodeStore.matches(code) {
            return "Choose a different passcode from your current one."
        }
        return nil
    }

    private func startCountdown(from seconds: Int) {
        countdown?.cancel()
        let step = self.step
        update(step, .lockedOut(seconds: seconds))
        countdown = Task { [weak self] in
            var left = seconds
            while left > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                left -= 1
                self.update(step, left > 0 ? .lockedOut(seconds: left) : .waiting)
            }
        }
    }

    private func update(_ step: Step, _ state: State) {
        self.step = step
        self.state = state
        onChange?(step, state)
    }
}
