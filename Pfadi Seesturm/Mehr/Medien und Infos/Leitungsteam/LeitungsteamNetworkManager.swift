//
//  LeitungsteamNetworkManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

class LeitungsteamNetworkManager {
    
    static let shared = LeitungsteamNetworkManager()
    
    func fetchMembers() async throws -> LeitungsteamResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        let urlString = Constants.SEESTURM_API_BASE_URL + "leitungsteam/members"
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
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(LeitungsteamResponse.self, from: data)
            
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