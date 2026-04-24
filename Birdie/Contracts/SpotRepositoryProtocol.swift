protocol SpotRepositoryProtocol {
    func fetchSpots(with filters: SpotFilterData) async throws -> [BirdSpot]
    
    func addSpot(_ spot: BirdSpot) async throws
    
    func deleteSpot(_ documentID: String) async throws

    func fetchSpottingCount(for userID: String) async throws -> Int
    
    func addSpotsBatch(_ spots: [BirdSpot]) async throws

}