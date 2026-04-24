//
//  FirestoreService.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import FirebaseFirestore
import Foundation

struct FirestoreService: SpotRepositoryProtocol {
    private let dbRef = Firestore.firestore()
    private let collectionRef: CollectionReference

    init(collection: String = "birdSpots") {
        self.collectionRef = dbRef.collection(collection)
    }

    // MARK: - Birdspot functions

    func addSpot(_ spot: BirdSpot) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            do {
                try collectionRef.addDocument(from: spot) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func deleteSpot(_ documentID: String) async throws {
        try await collectionRef.document(documentID).delete()
    }

    func fetchSpots(with filters: SpotFilterData) async throws
        -> [BirdSpot]
    {
        var query: Query =
            collectionRef
            .order(by: "date", descending: true)

        if !filters.selectedSpecies.isEmpty {
            query = query.whereField(
                "species",
                in: Array(filters.selectedSpecies)
            )
        }
        if filters.showOnlyMine,
            let uid = await AuthService.getCurrentUser()?.uid
        {
            query = query.whereField("userID", isEqualTo: uid)
        }

        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: BirdSpot.self) }
    }

    func fetchSpottingCount(for userID: String) async throws -> Int {
        let snapshot =
            try await collectionRef
            .whereField("userID", isEqualTo: userID)
            .getDocuments()

        return snapshot.documents.count
    }

    func addSpotsBatch(_ spots: [BirdSpot]) async throws {
        let batch = dbRef.batch()

        for spot in spots {
            let docRef = collectionRef.document()
            try batch.setData(from: spot, forDocument: docRef)
        }

        try await batch.commit()
        print("✅ Successfully committed batch of \(spots.count) bird spots.")
    }

}
