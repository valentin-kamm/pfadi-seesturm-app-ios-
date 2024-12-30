//
//  FirestoreManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import Foundation
import FirebaseFirestore

class FirestoreManager {
    
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // function to get live updates on a firestore collection
    func observeCollection<T: Decodable>(
        from collectionPath: String,
        as type: T.Type
    ) -> AsyncThrowingStream<[T], Error> {
        AsyncThrowingStream { continuation in
            let listener = db.collection(collectionPath).addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Datensätze konnten nicht geladen werden: \(error.localizedDescription)"))
                    return
                }
                guard let snapshot = snapshot else {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Datensätze konnten nicht geladen werden, da der Server keine Daten geliefert hat."))
                    return
                }
                if snapshot.isEmpty {
                    continuation.finish(throwing: PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Es existiert kein Datensatz in dieser Sammlung."))
                    return
                }
                do {
                    let decodedObjects: [T] = try snapshot.documents.compactMap { document in
                        return try document.data(as: T.self, with: .estimate)
                    }
                    continuation.yield(decodedObjects)
                    return
                }
                catch {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidData(message: "Datensätze konnten nicht geladen werden, da die übermittelten Daten fehlerhaft sind."))
                    return
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // function to get live updates on a single firestore document
    func observeSingleDocument<T: Decodable>(
        from collectionPath: String,
        documentId: String,
        as type: T.Type
    ) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            let listener = db.collection(collectionPath).document(documentId).addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Ein Datensatz konnte nicht geladen werden: \(error.localizedDescription)"))
                    return
                }
                guard let snapshot = snapshot else {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Ein Datensatz konnte nicht geladen werden, da der Server keine Daten geliefert hat."))
                    return
                }
                if !snapshot.exists {
                    continuation.finish(throwing: PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Der Datensatz existiert nicht."))
                    return
                }
                do {
                    let decodedObject = try snapshot.data(as: T.self, with: .estimate)
                    continuation.yield(decodedObject)
                    return
                }
                catch {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidData(message: "Ein Datensatz konnte nicht geladen werden, da die übermittelten Daten fehlerhaft sind."))
                    return
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // function to save an/abmeldung to firestore
    func saveAnAbmeldung(input: AktivitaetAnAbmeldung) async throws {
        let collection = "AnAbmeldungen"
        try await setFirestoreDocument(object: input, to: collection)
    }
    
    // function to read an entire collection from firebase
    func readCollection<T: Decodable>(
        from collectionPath: String,
        as type: T.Type,
        filter: ((Query) -> Query)? = nil
    ) async throws -> [T] {
        var query: Query = db.collection(collectionPath)
        if let f = filter {
            query = f(query)
        }
        let snapshot = try await query.getDocuments()
        guard !snapshot.isEmpty else {
            throw PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Kein Datensatz vorhanden.")
        }
        do {
            return try snapshot.documents.compactMap { document in
                var data: T = try document.data(as: T.self, with: .estimate)
                if var io = data as? StructWithIdField {
                    io.id = document.documentID
                    guard let finalObject = io as? T else {
                        throw PfadiSeesturmAppError.invalidData(message: "Datensätze konnten nicht gelesen werden. Die Daten sind ungültig.")
                    }
                    data = finalObject
                }
                return data
            }
        }
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Datensätze konnten nicht gelesen werden. Die Daten sind ungültig.")
        }
    }
    
    // function to read a single document from firestore and parse it
    func readSingleDocument<T: Decodable>(
        from collectionPath: String,
        documentId: String,
        as type: T.Type
    ) async throws -> T {
        let snapshot = try await db.collection(collectionPath).document(documentId).getDocument()
        guard snapshot.exists else {
            throw PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Der Datensatz existiert nicht.")
        }
        do {
            return try snapshot.data(as: T.self, with: .estimate)
        }
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Ein Datensatz konnte nicht gelesen werden. Die Daten sind ungültig.")
        }
    }
    
    // function to save any data to any collection
    func setFirestoreDocument<T: Codable>(
        object: T,
        to collection: String,
        to existingDocument: String? = nil
    ) async throws {
        let collection = db.collection(collection)
        let documentReference: DocumentReference
        if let docId = existingDocument {
            documentReference = collection.document(docId)
        }
        else {
            documentReference = collection.document()
        }
        try await documentReference.setData(try Firestore.Encoder().encode(object))
    }
    
    // function to convert a firebase timestamp to a date
    func convertFirestoreTimestampToDate(timestamp: Timestamp?) throws -> Date {
        if let ts = timestamp {
            return ts.dateValue()
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datum nicht vorhanden.")
        }
    }
    
    // function that converts two variables of type SeesturmLoadingState into one
    func combineTwoLoadingStates<T1, T2, R>(
        state1: SeesturmLoadingState<T1, PfadiSeesturmAppError>,
        state2: SeesturmLoadingState<T2, PfadiSeesturmAppError>,
        transform: (T1, T2) throws -> R
    ) -> SeesturmLoadingState<R, PfadiSeesturmAppError> {
        switch (state1, state2) {
        case (.none, .none):
            return .none
        case (.none, .loading):
            return .loading
        case (.none, .result(.failure(let error))):
            return .result(.failure(error))
        case (.none, .result(.success(_))):
            return .loading
        case (.none, .errorWithReload(_)):
            return .none

        case (.loading, .none):
            return .loading
        case (.loading, .loading):
            return .loading
        case (.loading, .result(.failure(let error))):
            return .result(.failure(error))
        case (.loading, .result(.success(_))):
            return .loading
        case (.loading, .errorWithReload(_)):
            return .loading

        case (.result(.failure(let error1)), .none):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .loading):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .result(.failure(_))):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .result(.success(_))):
            return .result(.failure(error1))
        case (.result(.failure(_)), .errorWithReload(_)):
            return .none
            
        case (.result(.success(_)), .none):
            return .loading
        case (.result(.success(_)), .loading):
            return .loading
        case (.result(.success(_)), .result(.failure(let error2))):
            return .result(.failure(error2))
        case (.result(.success(let data1)), .result(.success(let data2))):
            do {
                return .result(.success(try transform(data1, data2)))
            }
            catch {
                return .result(.failure(PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind ungültig.")))
            }
        case (.result(.success(_)), .errorWithReload(_)):
            return .none

        case (.errorWithReload(_), .none):
            return .none
        case (.errorWithReload(_), .loading):
            return .loading
        case (.errorWithReload(_), .result(.failure(_))):
            return .none
        case (.errorWithReload(_), .result(.success(_))):
            return .none
        case (.errorWithReload(_), .errorWithReload(_)):
            return .none
        }
    }
    
}
