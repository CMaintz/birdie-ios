//
//  FirestoreSpotRepository.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import FirebaseFirestore
import Foundation

final class FirestoreSpotRepository: SpotRepositoryProtocol {
    private let db: Firestore
    private let collection: CollectionReference

    init(db: Firestore = Firestore.firestore(), collectionName: String = "birdSpots") {
        self.db = db
        self.collection = db.collection(collectionName)
    }

    func fetchSpots(with filters: SpotFilterData, currentUserID: String?) async throws -> [BirdSpot] {
        var query: Query = collection.order(by: "date", descending: true)

        if !filters.selectedSpecies.isEmpty {
            query = query.whereField("species", in: Array(filters.selectedSpecies))
        }
        if filters.showOnlyMine, let currentUserID {
            query = query.whereField("userID", isEqualTo: currentUserID)
        }

        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                var spot = try document.data(as: BirdSpot.self)
                spot.id = document.documentID
                return spot
            } catch {
                Log.spots.error(
                    "Skipping malformed spot \(document.documentID, privacy: .public): \(error.localizedDescription, privacy: .public)"
                )
                return nil
            }
        }
    }

    func addSpot(_ spot: BirdSpot) async throws {
        var spot = spot
        spot.id = nil
        let data = try Firestore.Encoder().encode(spot)
        _ = try await collection.addDocument(data: data)
    }

    func deleteSpot(id: String) async throws {
        try await collection.document(id).delete()
    }

    func spotCount(for userID: String) async throws -> Int {
        let snapshot = try await collection
            .whereField("userID", isEqualTo: userID)
            .count
            .getAggregation(source: .server)
        return snapshot.count.intValue
    }

    func addSpots(_ spots: [BirdSpot]) async throws {
        let batch = db.batch()
        for var spot in spots {
            spot.id = nil
            try batch.setData(from: spot, forDocument: collection.document())
        }
        try await batch.commit()
        Log.spots.info("Committed batch of \(spots.count) spots")
    }
}
