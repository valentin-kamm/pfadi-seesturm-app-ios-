//
//  StufenbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

@MainActor
class StufenbereichViewModel: ObservableObject {
    
    @Published var stufe: SeesturmStufe
    
    @Published var rawAktivitaetenLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponse], PfadiSeesturmAppError>
    @Published var rawAbmeldungenLoadingState: SeesturmLoadingState<[TransformedAktivitaetAnAbmeldung], PfadiSeesturmAppError>
    
    @Published var selectedFilter: AktivitaetAktion
    
    init(
        stufe: SeesturmStufe,
        rawAktivitaetenLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponse], PfadiSeesturmAppError> = .none,
        rawAbmeldungenLoadingState: SeesturmLoadingState<[TransformedAktivitaetAnAbmeldung], PfadiSeesturmAppError> = .none,
        selectedFilter: AktivitaetAktion? = nil
    ) {
        self.stufe = stufe
        self.rawAktivitaetenLoadingState = rawAktivitaetenLoadingState
        self.rawAbmeldungenLoadingState = rawAbmeldungenLoadingState
        self.selectedFilter = selectedFilter ?? stufe.allowedActionActivities.first ?? .abmelden
    }
    
    var abmeldungenLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponseWithAnAbmeldungen], PfadiSeesturmAppError> {
        FirestoreManager.shared.combineTwoLoadingStates(
            state1: rawAktivitaetenLoadingState,
            state2: rawAbmeldungenLoadingState) { aktivitaeten, abmeldungen in
                return aktivitaeten.map { $0.toAktivitaetWithAnAbmeldungen(anAbmeldungen: abmeldungen) }
            }
    }
    
    // function to start fetching data
    func fetchData(isPullToRefresh: Bool) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchAnAbmeldungen(isPullToRefresh: isPullToRefresh) }
            group.addTask { await self.fetchAktivitaeten(isPullToRefresh: isPullToRefresh) }
        }
    }
    
    // function to fetch data from firestore
    private func fetchAnAbmeldungen(isPullToRefresh: Bool) async {
        withAnimation {
            self.rawAbmeldungenLoadingState = isPullToRefresh ? rawAbmeldungenLoadingState : .loading
        }
        do {
            let data = try await FirestoreManager.shared.readCollection(
                from: "AnAbmeldungen",
                as: AktivitaetAnAbmeldung.self) { query in
                    query.whereField("stufenId", in: [self.stufe.id])
                }
            let transformedData = try data.compactMap { abmeldung in
                return try abmeldung.toTransformedAktivitaetAnAbmeldung()
            }
            withAnimation {
                self.rawAbmeldungenLoadingState = .result(.success(transformedData))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .firestoreDocumentDoesNotExistError = pfadiSeesturmError {
                withAnimation {
                    self.rawAbmeldungenLoadingState = .result(.success([]))
                }
            }
            else {
                withAnimation {
                    self.rawAbmeldungenLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.rawAbmeldungenLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    
    // function to fetch aktivitäten
    private func fetchAktivitaeten(isPullToRefresh: Bool) async {
        withAnimation {
            self.rawAktivitaetenLoadingState = isPullToRefresh ? rawAktivitaetenLoadingState : .loading
        }
        do {
            let response = try await CalendarNetworkManager.shared.fetchEvents(calendarId: stufe.calendar.info.calendarId, includePast: true, maxResults: 100)
            let transformedEvents = try response.items.compactMap { event in
                return try event.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            }
            withAnimation {
                self.rawAktivitaetenLoadingState = .result(.success(transformedEvents))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                self.rawAktivitaetenLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.rawAktivitaetenLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    
}
