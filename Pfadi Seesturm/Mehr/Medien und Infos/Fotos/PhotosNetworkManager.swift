//
//  PhotosNetworkManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import Foundation

class PhotosNetworkManager {
    
    static let shared = PhotosNetworkManager()
    
    // MARK: - Gallerien für ein Pfadijahr laden
    func fetchPhotos(id: String) async throws -> ImagesResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        let urlString = Constants.SEESTURM_API_BASE_URL + "photos/images/\(id)"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL " + urlString + " ist ungültig.")
        }
        
        do {
            
            // Make network call
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
            }
            guard httpResponse.statusCode == 200 else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (HTTP-Statuscode \(httpResponse.statusCode)).")
            }
            
            // check that data is not empty
            guard !data.isEmpty else {
                throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind leer.")
            }
            
            return try JSONDecoder().decode(ImagesResponse.self, from: data)
            
        }
        // throw the error that possibly has occurred during the date conversion
        catch let error as PfadiSeesturmAppError {
            throw error
        }
        // catch and throw network errors
        catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw PfadiSeesturmAppError.internetConnectionError(message: "Keine Internetverbindung.")
            }
            else if error.code == .cancelled {
                throw PfadiSeesturmAppError.cancellationError(message: "Der Vorgang wurde abgebrochen.")
            }
            else {
                throw PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription).")
            }
        }
        // throw any other errors that have occurred in the do catch block
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind fehlerhaft.")
        }
    }
    
    // MARK: - Gallerien für ein Pfadijahr laden
    func fetchGalleries(id: String) async throws -> GalleriesResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        let urlString = Constants.SEESTURM_API_BASE_URL + "photos/albums/\(id)"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL " + urlString + " ist ungültig.")
        }
        
        do {
            
            // Make network call
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
            }
            guard httpResponse.statusCode == 200 else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (HTTP-Statuscode \(httpResponse.statusCode)).")
            }
            
            // check that data is not empty
            guard !data.isEmpty else {
                throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind leer.")
            }
            
            return try JSONDecoder().decode(GalleriesResponse.self, from: data)
            
        }
        // throw the error that possibly has occurred during the date conversion
        catch let error as PfadiSeesturmAppError {
            throw error
        }
        // catch and throw network errors
        catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw PfadiSeesturmAppError.internetConnectionError(message: "Keine Internetverbindung.")
            }
            else if error.code == .cancelled {
                throw PfadiSeesturmAppError.cancellationError(message: "Der Vorgang wurde abgebrochen.")
            }
            else {
                throw PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription).")
            }
        }
        // throw any other errors that have occurred in the do catch block
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind fehlerhaft.")
        }
    }
    
    // MARK: - Pfadijahre laden
    func fetchPfadijahre() async throws -> PfadijahreResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        let urlString = Constants.SEESTURM_API_BASE_URL + "photos/pfadijahre"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL " + urlString + " ist ungültig.")
        }
        
        do {
            
            // Make network call
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
            }
            guard httpResponse.statusCode == 200 else {
                throw PfadiSeesturmAppError.invalidResponse(message: "Ungültige Antwort vom Server (HTTP-Statuscode \(httpResponse.statusCode)).")
            }
            
            // check that data is not empty
            guard !data.isEmpty else {
                throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind leer.")
            }
            
            return try JSONDecoder().decode(PfadijahreResponse.self, from: data)
            
        }
        // throw the error that possibly has occurred during the date conversion
        catch let error as PfadiSeesturmAppError {
            throw error
        }
        // catch and throw network errors
        catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw PfadiSeesturmAppError.internetConnectionError(message: "Keine Internetverbindung.")
            }
            else if error.code == .cancelled {
                throw PfadiSeesturmAppError.cancellationError(message: "Der Vorgang wurde abgebrochen.")
            }
            else {
                throw PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription).")
            }
        }
        // throw any other errors that have occurred in the do catch block
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind fehlerhaft.")
        }
    }
}
