
protocol UserControllerProtocol {
    var currentUser: BirdieUser? { get }
    func loadCurrentUser() 
    func updateDisplayName(_ name: String) async throws
    func updatePhotoURL(_ urlString: String) async throws
    func updateEmail(_ newEmail: String) async throws
    func updatePassword(_ newPassword: String) async throws
    func getDisplayName() -> String?
    func getUserID() -> String?
    func getEmail() -> String?
    func getPhotoURL() -> URL?
}