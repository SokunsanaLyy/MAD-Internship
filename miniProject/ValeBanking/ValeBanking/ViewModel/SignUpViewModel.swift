//
//  SignUpViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 6/11/2026.
//

import Foundation

// MARK: - SignUpViewModel

final class SignUpViewModel {

    enum Field {
        case fullName, email, phone, password, confirmPassword
    }

    enum State {
        case editing
        case sending
        case failed(String, Field?)
        case created(email: String)
    }

    var onChange: ((State) -> Void)?

    private(set) var state: State = .editing {
        didSet { onChange?(state) }
    }

    private let service = BankService()

    // MARK: Validation

    /// Returns the first problem in the form, or nil when everything is OK.
    func validate(fullName: String, email: String, phone: String,
                  password: String, confirmPassword: String) -> (String, Field)? {
        if fullName.trimmingCharacters(in: .whitespaces).split(separator: " ").count < 2 {
            return ("Enter your first and last name.", .fullName)
        }
        if !email.contains("@") || !email.contains(".") {
            return ("Enter a valid email address.", .email)
        }
        let digits = phone.filter(\.isNumber)
        if digits.count < 8 {
            return ("Enter a phone number with at least 8 digits.", .phone)
        }
        if password.count < 8 || !password.contains(where: \.isLetter) || !password.contains(where: \.isNumber) {
            return ("Use at least 8 characters, with letters and numbers.", .password)
        }
        if password != confirmPassword {
            return ("The passwords don't match.", .confirmPassword)
        }
        return nil
    }

    // MARK: Submit

    func signUp(fullName: String, email: String, phone: String,
                password: String, confirmPassword: String) {
        let name = fullName.trimmingCharacters(in: .whitespaces)
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        if let problem = validate(fullName: name, email: cleanEmail, phone: phone,
                                  password: password, confirmPassword: confirmPassword) {
            state = .failed(problem.0, problem.1)
            return
        }

        state = .sending
        let request = SignUpRequest(fullName: name, email: cleanEmail,
                                    phone: phone.filter(\.isNumber), password: password)
        Task {
            do {
                let result = try await service.signUp(request)
                self.state = .created(email: result.email)
            } catch {
                self.state = .failed(error.localizedDescription, nil)
            }
        }
    }
}
