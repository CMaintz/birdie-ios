import Foundation

enum FormError: LocalizedError, Equatable {
    case missingCredentials
    case missingRegistrationFields
    case invalidEmail
    case passwordTooShort(minimum: Int)
    case passwordsDoNotMatch
    case missingSpecies
    case missingLocation
    case notSignedIn
    case notOwner

    var errorDescription: String? {
        switch self {
        case .missingCredentials: "Email and password are required."
        case .missingRegistrationFields: "Name, email and password are required."
        case .invalidEmail: "That doesn't look like a valid email address."
        case .passwordTooShort(let minimum): "Passwords must be at least \(minimum) characters."
        case .passwordsDoNotMatch: "Passwords do not match."
        case .missingSpecies: "Pick the species you saw."
        case .missingLocation: "Your location isn't available yet. Try again in a moment."
        case .notSignedIn: "You need to be signed in to do that."
        case .notOwner: "You can only delete your own sightings."
        }
    }
}

enum FormValidation {
    /// Firebase Auth rejects shorter passwords.
    static let minimumPasswordLength = 6

    static func isPlausibleEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domain = parts[1]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
            && !email.contains(" ")
    }

    static func validateLogin(email: String, password: String) throws {
        guard !email.trimmed.isEmpty, !password.isEmpty else {
            throw FormError.missingCredentials
        }
    }

    static func validateRegistration(
        displayName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) throws {
        guard !displayName.trimmed.isEmpty, !email.trimmed.isEmpty, !password.isEmpty else {
            throw FormError.missingRegistrationFields
        }
        guard isPlausibleEmail(email.trimmed) else { throw FormError.invalidEmail }
        try validateNewPassword(password, confirmation: confirmPassword)
    }

    static func validateNewPassword(_ password: String, confirmation: String) throws {
        guard password.count >= minimumPasswordLength else {
            throw FormError.passwordTooShort(minimum: minimumPasswordLength)
        }
        guard password == confirmation else { throw FormError.passwordsDoNotMatch }
    }
}

/// The subset of profile fields a user actually changed. `nil` means "leave as is".
struct ProfileChanges: Equatable {
    var displayName: String?
    var photoURL: URL?
    var email: String?
    var password: String?

    var isEmpty: Bool {
        displayName == nil && photoURL == nil && email == nil && password == nil
    }

    /// Compares form input with the current user and validates whatever changed.
    static func diff(
        from user: BirdieUser,
        displayName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) throws -> ProfileChanges {
        var changes = ProfileChanges()

        let name = displayName.trimmed
        if !name.isEmpty, name != user.displayName {
            changes.displayName = name
        }

        let newEmail = email.trimmed
        if !newEmail.isEmpty, newEmail != user.email {
            guard FormValidation.isPlausibleEmail(newEmail) else { throw FormError.invalidEmail }
            changes.email = newEmail
        }

        if !password.isEmpty || !confirmPassword.isEmpty {
            try FormValidation.validateNewPassword(password, confirmation: confirmPassword)
            changes.password = password
        }

        return changes
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
