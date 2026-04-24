protocol AuthServiceProtocol {
    func createUser(
        _ photoURL: String?,
        _ displayname: String,
        _ email: String,
        _ password: String,
    ) async throws -> User
        
    func signIn(_ email: String, _ password: String) async throws -> User

    func signOut() throws
    
    func getCurrentUser() async -> User?

    func editProfile(
        displayName: String?,
        photoURL: String?,
        email: String?,
        password: String?
    ) async

    func manualPhotoSetter(from url: String)
    
}