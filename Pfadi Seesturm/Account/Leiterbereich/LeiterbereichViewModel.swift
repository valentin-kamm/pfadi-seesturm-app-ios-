//
//  LeiterbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

import SwiftUI

@MainActor
class LeiterbereichViewModel: ObservableObject {
    
    // current user
    private var currentUser: FirebaseHitobitoUser
    
    // variables for sending schöpflialarm
    @Published var sendSchöpflialarmLoadingState: SeesturmLoadingState<String, PfadiSeesturmAppError>
    @Published var schöpflialarmMessage: String
    @Published var showLocationSettingsAlert: Bool
    @Published var showLocationAccuracySettingsAlert: Bool
    @Published var showNotificationsSettingsAlert: Bool
    @Published var showWirklichSendenAlert: Bool
    @Published var wirklichSendenContinuation: CheckedContinuation<Void, Error>?
    
    // variables for reading termine
    @Published var termineLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponse], PfadiSeesturmAppError>
    let calendarNetworkManager = CalendarNetworkManager.shared
    
    // variables for reading essensbestellungen
    
    // variables for reading users
    @Published private var rawUsersLoadingState: SeesturmLoadingState<[FirebaseHitobitoUser], PfadiSeesturmAppError>
    private var usersObservationTask: Task<Void, Never>?
    
    // variables for reading last schöpflialarm
    @Published private var rawLastSchöpflialarmLoadingState: SeesturmLoadingState<Schöpflialarm?, PfadiSeesturmAppError>
    private var schöpflialarmObservationTask: Task<Void, Never>?
    
    // variable for selected Stufen
    private var userDefaultsKeySelectedStufen = "selectedStufenLeiterbereich_V2"
    @Published var selectedStufen: Set<SeesturmStufe> = [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio] {
        didSet {
            saveSelectedStufen()
        }
    }
    
    init(
        currentUser: FirebaseHitobitoUser,
        sendSchöpflialarmLoadingState: SeesturmLoadingState<String, PfadiSeesturmAppError> = .none,
        schöpflialarmMessage: String = "",
        showLocationSettingsAlert: Bool = false,
        showLocationAccuracySettingsAlert: Bool = false,
        showNotificationsSettingsAlert: Bool = false,
        showWirklichSendenAlert: Bool = false,
        termineLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponse], PfadiSeesturmAppError> = .none,
        rawUsersLoadingState: SeesturmLoadingState<[FirebaseHitobitoUser], PfadiSeesturmAppError> = .none,
        usersObservationTask: Task<Void, Never>? = nil,
        rawLastSchöpflialarmLoadingState: SeesturmLoadingState<Schöpflialarm?, PfadiSeesturmAppError> = .none,
        schöpflialarmObservationTask: Task<Void, Never>? = nil
    ) {
        self.currentUser = currentUser
        self.sendSchöpflialarmLoadingState = sendSchöpflialarmLoadingState
        self.schöpflialarmMessage = schöpflialarmMessage
        self.showLocationSettingsAlert = showLocationSettingsAlert
        self.showLocationAccuracySettingsAlert = showLocationAccuracySettingsAlert
        self.showNotificationsSettingsAlert = showNotificationsSettingsAlert
        self.showWirklichSendenAlert = showWirklichSendenAlert
        self.termineLoadingState = termineLoadingState
        self.rawUsersLoadingState = rawUsersLoadingState
        self.usersObservationTask = usersObservationTask
        self.rawLastSchöpflialarmLoadingState = rawLastSchöpflialarmLoadingState
        self.schöpflialarmObservationTask = schöpflialarmObservationTask
        
        startObservingLeiterbereichData()
        withAnimation {
            self.selectedStufen = getSelectedStufen()
        }
    }
    
    deinit {
        schöpflialarmObservationTask?.cancel()
        schöpflialarmObservationTask = nil
        usersObservationTask?.cancel()
        usersObservationTask = nil
    }
    
    // variables for reading combined values for schöpflialarm and essensbestellungen
    var lastSchöpflialarmLoadingState: SeesturmLoadingState<TransformedSchöpflialarm?, PfadiSeesturmAppError> {
        return FirestoreManager.shared.combineTwoLoadingStates(
            state1: rawLastSchöpflialarmLoadingState,
            state2: rawUsersLoadingState) { schöpflialarm, users in
                if let sa = schöpflialarm {
                    return try sa.toTransformedSchöpflialarm(users: users)
                }
                else {
                    return nil
                }
            }
    }
    
    // function to start all observers
    func startObservingLeiterbereichData() {
        observeSchöpflialarm()
        observeUsers()
    }
    
    // function that observes users
    private func observeUsers() {
        usersObservationTask?.cancel()
        usersObservationTask = nil
        withAnimation {
            rawUsersLoadingState = .loading
        }
        usersObservationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
            do {
                for try await data in FirestoreManager.shared.observeCollection(from: "users", as: FirebaseHitobitoUser.self) {
                    withAnimation {
                        self.rawUsersLoadingState = .result(.success(data))
                    }
                }
                withAnimation {
                    self.rawUsersLoadingState = .none
                }
            }
            catch let pfadiSeesturmError as PfadiSeesturmAppError {
                if case .firestoreDocumentDoesNotExistError = pfadiSeesturmError {
                    withAnimation {
                        self.rawUsersLoadingState = .result(.success([]))
                    }
                }
                else {
                    withAnimation {
                        self.rawUsersLoadingState = .result(.failure(pfadiSeesturmError))
                    }
                }
            }
            catch {
                let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
                withAnimation {
                    self.rawUsersLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
    }
    
    // function to observe last schöpflialarm
    private func observeSchöpflialarm() {
        schöpflialarmObservationTask?.cancel()
        schöpflialarmObservationTask = nil
        withAnimation {
            rawLastSchöpflialarmLoadingState = .loading
        }
        schöpflialarmObservationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
            do {
                for try await data in FirestoreManager.shared.observeSingleDocument(from: "leiterbereich", documentId: "schopflialarm", as: Schöpflialarm.self) {
                    withAnimation {
                        self.rawLastSchöpflialarmLoadingState = .result(.success(data))
                    }
                }
                // observation has stopped
                withAnimation {
                    self.rawLastSchöpflialarmLoadingState = .none
                }
            }
            catch let pfadiSeesturmError as PfadiSeesturmAppError {
                if case .firestoreDocumentDoesNotExistError = pfadiSeesturmError {
                    withAnimation {
                        self.rawLastSchöpflialarmLoadingState = .result(.success(nil))
                    }
                }
                else {
                    withAnimation {
                        self.rawLastSchöpflialarmLoadingState = .result(.failure(pfadiSeesturmError))
                    }
                }
            }
            catch {
                let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
                withAnimation {
                    self.rawLastSchöpflialarmLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
    }
    
    // function to send schöpflialarm
    func sendSchöpflialarm() async {
        if schöpflialarmMessage.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showWirklichSendenAlert = true
            do {
                try await withCheckedThrowingContinuation { continuation in
                    self.wirklichSendenContinuation = continuation
                }
            }
            catch {
                withAnimation {
                    self.sendSchöpflialarmLoadingState = .none
                }
                return
            }
        }
        let sendingManager = SchöpflialarmSendingManager(message: self.schöpflialarmMessage, user: currentUser)
        await sendingManager.sendSchöpflialarm(
            showNotificationsSettingsAlert: {
                self.showNotificationsSettingsAlert = true
            },
            showLocationSettingsAlert: {
                self.showLocationSettingsAlert = true
            },
            showLocationAccuracySettingsAlert: {
                self.showLocationAccuracySettingsAlert = true
            },
            onNewState: { newState in
                withAnimation {
                    self.sendSchöpflialarmLoadingState = newState
                }
            }
        )
    }
    
    // function to fetch the next 3 events
    func fetchNext3LeiterbereichEvents(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.termineLoadingState = isPullToRefresh ? termineLoadingState : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: CalendarType.termineLeitungsteam.info.calendarId, includePast: false, maxResults: 3)
            let transformedEvents = try response.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            }
            withAnimation {
                self.termineLoadingState = .result(.success(transformedEvents))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.termineLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.termineLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.termineLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to get the selected stufen
    private func getSelectedStufen() -> Set<SeesturmStufe> {
        let data = UserDefaults().data(forKey: userDefaultsKeySelectedStufen) ?? Data()
        guard !data.isEmpty else {
            return [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio]
        }
        let set = try? JSONDecoder().decode(Set<SeesturmStufe>.self, from: data)
        return set ?? [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio]
    }
    
    // function to save the selected stufen
    private func saveSelectedStufen() {
        let data = try? JSONEncoder().encode(selectedStufen)
        UserDefaults().set(data, forKey: userDefaultsKeySelectedStufen)
    }
    
}
