protocol StorageServiceProtocol {
    func uploadImage(_ imageData: Data, path: String) async throws -> URL
    func deleteImage(at path: String) async throws
    func getDownloadURL(for path: String) async throws -> URL
} // TODO: integrate with Firebase Storage