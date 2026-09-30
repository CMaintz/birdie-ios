import Foundation
import Testing
@testable import Birdie

struct FormValidationTests {
    @Test(arguments: ["a@b.dk", "albert.madsen@example.com", "x+tag@sub.domain.org"])
    func acceptsPlausibleEmails(_ email: String) {
        #expect(FormValidation.isPlausibleEmail(email))
    }

    @Test(arguments: ["", "plainaddress", "@example.com", "user@", "user@domain", "user@.com", "user@domain.", "a b@c.dk", "a@b@c.dk"])
    func rejectsImplausibleEmails(_ email: String) {
        #expect(!FormValidation.isPlausibleEmail(email))
    }

    @Test func loginRequiresEmailAndPassword() throws {
        #expect(throws: FormError.missingCredentials) {
            try FormValidation.validateLogin(email: "  ", password: "secret")
        }
        #expect(throws: FormError.missingCredentials) {
            try FormValidation.validateLogin(email: "a@b.dk", password: "")
        }
        try FormValidation.validateLogin(email: "a@b.dk", password: "secret")
    }

    @Test func registrationRequiresAllFields() {
        #expect(throws: FormError.missingRegistrationFields) {
            try FormValidation.validateRegistration(
                displayName: " ", email: "a@b.dk", password: "secret1", confirmPassword: "secret1"
            )
        }
    }

    @Test func registrationRejectsBadEmail() {
        #expect(throws: FormError.invalidEmail) {
            try FormValidation.validateRegistration(
                displayName: "Al", email: "not-an-email", password: "secret1", confirmPassword: "secret1"
            )
        }
    }

    @Test func registrationRejectsShortPassword() {
        #expect(throws: FormError.passwordTooShort(minimum: 6)) {
            try FormValidation.validateRegistration(
                displayName: "Al", email: "a@b.dk", password: "12345", confirmPassword: "12345"
            )
        }
    }

    @Test func registrationRejectsMismatchedPasswords() {
        #expect(throws: FormError.passwordsDoNotMatch) {
            try FormValidation.validateRegistration(
                displayName: "Al", email: "a@b.dk", password: "secret1", confirmPassword: "secret2"
            )
        }
    }

    @Test func registrationAcceptsValidInput() throws {
        try FormValidation.validateRegistration(
            displayName: "Al", email: " a@b.dk ", password: "secret1", confirmPassword: "secret1"
        )
    }

    @Test func everyFormErrorHasAMessage() {
        let errors: [FormError] = [
            .missingCredentials, .missingRegistrationFields, .invalidEmail,
            .passwordTooShort(minimum: 6), .passwordsDoNotMatch, .missingSpecies,
            .missingLocation, .notSignedIn, .notOwner,
        ]
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}

struct ProfileChangesTests {
    private let user = BirdieUser(id: "u1", email: "old@birdie.dk", displayName: "Old Name", imageURL: nil)

    @Test func unchangedFormProducesNoChanges() throws {
        let changes = try ProfileChanges.diff(
            from: user, displayName: "Old Name", email: "old@birdie.dk", password: "", confirmPassword: ""
        )
        #expect(changes.isEmpty)
    }

    @Test func blankFieldsAreIgnored() throws {
        let changes = try ProfileChanges.diff(
            from: user, displayName: "   ", email: "", password: "", confirmPassword: ""
        )
        #expect(changes.isEmpty)
    }

    @Test func picksUpTrimmedNameAndEmail() throws {
        let changes = try ProfileChanges.diff(
            from: user, displayName: " New Name ", email: "new@birdie.dk ", password: "", confirmPassword: ""
        )
        #expect(changes == ProfileChanges(displayName: "New Name", email: "new@birdie.dk"))
    }

    @Test func passwordChangeMustBeConfirmed() {
        #expect(throws: FormError.passwordsDoNotMatch) {
            try ProfileChanges.diff(
                from: user, displayName: "", email: "", password: "secret1", confirmPassword: "secret"
            )
        }
    }

    @Test func confirmationWithoutPasswordIsRejected() {
        #expect(throws: FormError.passwordTooShort(minimum: 6)) {
            try ProfileChanges.diff(
                from: user, displayName: "", email: "", password: "", confirmPassword: "secret1"
            )
        }
    }

    @Test func invalidNewEmailIsRejected() {
        #expect(throws: FormError.invalidEmail) {
            try ProfileChanges.diff(
                from: user, displayName: "", email: "nope", password: "", confirmPassword: ""
            )
        }
    }

    @Test func validPasswordChangeIsIncluded() throws {
        let changes = try ProfileChanges.diff(
            from: user, displayName: "", email: "", password: "secret1", confirmPassword: "secret1"
        )
        #expect(changes == ProfileChanges(password: "secret1"))
    }
}
