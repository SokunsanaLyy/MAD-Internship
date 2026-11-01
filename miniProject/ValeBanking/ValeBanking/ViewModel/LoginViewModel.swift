//
//  LoginViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import Foundation

final class LoginViewModel {

    enum State {
        case idle
        case loading
        case failed(String)
        case codeSent
    }

    var onChange: ((State) -> Void)?

    private(set) var state: State = .idle {
        didSet { onChange?(state) }
    }

    func isValid(email: String, password: String) -> Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    func signIn(email: String, password: String) {
        let email = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard isValid(email: email, password: password) else {
            state = .failed("Enter a valid email and a password of at least 6 characters.")
            return
        }
        
        state = .loading
        
        Task {
            do {
                try await SessionStore.shared.signIn(email: email, password: password)
                self.state = .codeSent
            } catch {
                self.state = .failed(error.localizedDescription)
            }
            
        }
    }
}
