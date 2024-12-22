//
//  AktivitaetDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//
import SwiftUI

@MainActor
class AktivitaetDetailViewModel: ObservableObject {
    
    private let calendarNetworkManager = CalendarNetworkManager.shared
    
    @Published var currentEventId: String = ""
    @Published var event: TransformedCalendarEventResponse = TransformedCalendarEventResponse()
    @Published var loadingState: SeesturmLoadingState = .none
    
    // function to fetch the desired post using the network manager
    func fetchEvent(by eventId: String, calendarId: String, isPullToRefresh: Bool) async {
        
        currentEventId = eventId
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .loading
        }
        
        do {
            let event = try await calendarNetworkManager.fetchEvent(calendarId: calendarId, eventId: eventId)
            let transformedEvent = try event.toTransformedEvent(calendarTimeZoneIdentifier: "Europe/Zurich")
            withAnimation {
                self.event = transformedEvent
                self.loadingState = .success
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.loadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.loadingState = .error(error: pfadiSeesturmError)
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.loadingState = .error(error: pfadiSeesturmError)
            }
        }
        
    }
}
