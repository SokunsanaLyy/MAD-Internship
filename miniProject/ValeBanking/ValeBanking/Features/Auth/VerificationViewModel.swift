//
//  VerificationViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import Foundation

final class VerificationViewModel {

    enum State {
        case idle
        case loading
        case failed(String)
    }

    var onChange: ((State) -> Void)?
    var onTick: ((Int) -> Void)?

    private(set) var state: State = .idle {
        didSet { onChange?(state) }
    }

    private(set) var secondsLeft = AppConfig.resendSeconds
    private var countdown: Task<Void, Never>?

    var phoneLast4: String { SessionStore.shared.phoneLast4 }

    // MARK: Countdown

    func startCountdown() {
        countdown?.cancel()
        secondsLeft = AppConfig.resendSeconds
        onTick?(secondsLeft)

        countdown = Task { [weak self] in
            for _ in 0..<AppConfig.resendSeconds {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                self.secondsLeft -= 1
                self.onTick?(self.secondsLeft)
            }
        }
    }

    func stopCountdown() {
        countdown?.cancel()
    }

    // MARK: Verify

    func verify(code: String) {
        guard code.count == AppConfig.otpLength else {
            state = .failed("Enter all \(AppConfig.otpLength) digits.")
            return
        }
        state = .loading
        Task {
            do {
                try await SessionStore.shared.verify(code: code)
                self.stopCountdown()
                // SessionStore switches to the tab bar
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
}

