protocol UserRepositoryProtocol {
    func fetchUserProfile(_ userID: String) async throws -> UserProfile
    func updateUserStats(_ userID: String, spotCount: Int) async throws
    func fetchUserPreferences(_ userID: String) async throws -> UserPreferences
} //TODO: add user preferences and information to firestore, instead of 
// using Auth for displayname and picture etc.