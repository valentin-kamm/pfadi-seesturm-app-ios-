//
//  GoogleCalendarNetworkManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 03.11.2024.
//

import Foundation

class CalendarNetworkManager {
    
    static let shared = CalendarNetworkManager()
    
    // fetch single event by id
    func fetchEvent(calendarId: String, eventId: String) async throws -> CalendarEventResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        // construct and check url
        let urlString = Constants.GOOGLE_CALENDAR_BASE_URL + "byEventId?calendarId=\(calendarId)&eventId=\(eventId)"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL ist ungültig.")
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
            
            return try JSONDecoder().decode(CalendarEventResponse.self, from: data)
            
        }
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
    
    // fetch events
    func fetchEvents(calendarId: String, includePast: Bool, maxResults: Int) async throws -> CalendarResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        // construct and check url
        let urlString = Constants.GOOGLE_CALENDAR_BASE_URL + "byCalendarId?calendarId=\(calendarId)&includePast=\(includePast)&maxResults=\(maxResults)"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL ist ungültig.")
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
            
            return try JSONDecoder().decode(CalendarResponse.self, from: data)
            
        }
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
    
    // fetch events based on a page token
    func fetchEvents(by pageToken: String, calendarId: String, maxResults: Int) async throws -> CalendarResponse {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        // construct and check url
        let urlString = Constants.GOOGLE_CALENDAR_BASE_URL + "byPageId?calendarId=\(calendarId)&pageToken=\(pageToken)&maxResults=\(maxResults)"
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmAppError.invalidUrl(message: "Die URL ist ungültig.")
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
            
            return try JSONDecoder().decode(CalendarResponse.self, from: data)
            
        }
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
