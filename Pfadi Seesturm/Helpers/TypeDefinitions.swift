//
//  TypeDefinitions.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

// notification topics
enum SeesturmNotificationTopic: Identifiable {
    case schöpflialarm
    case schöpflialarmReaktion
    case aktuell
    case biberAktivitäten
    case wolfAktivitäten
    case pfadiAktivitäten
    case pioAktivitäten
    
    var id: UUID {
        switch self {
        case .schöpflialarm:
            UUID()
        case .schöpflialarmReaktion:
            UUID()
        case .aktuell:
            UUID()
        case .biberAktivitäten:
            UUID()
        case .wolfAktivitäten:
            UUID()
        case .pfadiAktivitäten:
            UUID()
        case .pioAktivitäten:
            UUID()
        }
    }
    
    var topicString: String {
        switch self {
        case .schöpflialarm:
            "schoepflialarm_v2"
        case .schöpflialarmReaktion:
            "schoepflialarmReaktion_v2"
        case .aktuell:
            "aktuell_v2"
        case .biberAktivitäten:
            "aktivitaetBiberstufe_v2"
        case .wolfAktivitäten:
            "aktivitaetWolfsstufe_v2"
        case .pfadiAktivitäten:
            "aktivitaetPfadistufe_v2"
        case .pioAktivitäten:
            "aktivitaetPiostufe_v2"
        }
    }
    
}


// stufen der pfadi seesturm
enum SeesturmStufe: Codable, Comparable, Hashable {
    case biber
    case wolf
    case pfadi
    case pio
    
    init(id: Int) throws {
        switch id {
        case 0:
            self = .biber
        case 1:
            self = .wolf
        case 2:
            self = .pfadi
        case 3:
            self = .pio
        default:
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte Stufe.")
        }
    }
    
    var id: Int {
        switch self {
        case .biber:
            return 0
        case .wolf:
            return 1
        case .pfadi:
            return 2
        case .pio:
            return 3
        }
    }
    var description: String {
        switch self {
        case .biber:
            return "Biberstufe"
        case .wolf:
            return "Wolfsstufe"
        case .pfadi:
            return "Pfadistufe"
        case .pio:
            return "Piostufe"
        }
    }
    var calendar: CalendarType {
        switch self {
        case .biber:
            return .aktivitaetenBiberstufe
        case .wolf:
            return .aktivitaetenWolfsstufe
        case .pfadi:
            return .aktivitaetenPfadistufe
        case .pio:
            return .aktivitaetenPiostufe
        }
    }
    var icon: Image {
        switch self {
        case .biber:
            return Image("biber")
        case .wolf:
            return Image("wolf")
        case .pfadi:
            return Image("pfadi")
        case .pio:
            return Image("pio")
        }
    }
    var color: Color {
        switch self {
        case .biber:
            return Color.SEESTURM_RED
        case .wolf:
            return Color.wolfsstufeColor
        case .pfadi:
            return Color.SEESTURM_BLUE
        case .pio:
            return Color.SEESTURM_GREEN
        }
    }
    var allowedActionActivities: [AktivitaetAktion] {
        switch self {
        case .biber:
            return [.anmelden, .abmelden]
        case .wolf:
            return [.abmelden]
        case .pfadi:
            return [.abmelden]
        case .pio:
            return [.abmelden]
        }
    }
}

// aktivitäten erlaubte aktionen
enum AktivitaetAktion: CaseIterable, Identifiable, Codable {
    case anmelden
    case abmelden
    
    init(id: Int) throws {
        switch id {
        case 1:
            self = .anmelden
        case 0:
            self = .abmelden
        default:
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte An-/Abmelde-Art.")
        }
    }
    
    var id: Int {
        switch self {
        case .anmelden:
            return 1
        case .abmelden:
            return 0
        }
    }
    var nomen: String {
        switch self {
        case .anmelden:
            return "Anmeldung"
        case .abmelden:
            return "Abmeldung"
        }
    }
    var nomenMehrzahl: String {
        switch self {
        case .anmelden:
            return "Anmeldungen"
        case .abmelden:
            return "Abmeldungen"
        }
    }
    var verb: String {
        switch self {
        case .anmelden:
            return "anmelden"
        case .abmelden:
            return "abmelden"
        }
    }
    var icon: String {
        switch self {
        case .anmelden:
            return "checkmark.circle"
        case .abmelden:
            return "xmark.circle"
        }
    }
}

// aktivitäten erlaubte aktionen
enum AppMainTab {
    case home
    case aktuell
    case anlässe
    case mehr
    case leiterbereich
    
    var id: Int {
        switch self {
        case .home:
            return 0
        case .aktuell:
            return 1
        case .anlässe:
            return 2
        case .mehr:
            return 3
        case .leiterbereich:
            return 4
        }
    }
}

// allowed styles of button
enum CustomButtonStyle {
    case primary
    case secondary
    case tertiary(color: Color = .SEESTURM_GREEN)
}

// error types for network calls
enum PfadiSeesturmAppError: LocalizedError {
    
    case invalidUrl(message: String)
    case invalidResponse(message: String)
    case invalidData(message: String)
    case dateDecodingError(message: String)
    case invalidInput(message: String)
    case internetConnectionError(message: String)
    case cancellationError(message: String)
    case authError(message: String)
    case messagingPermissionError(message: String)
    case messagingError(message: String)
    case locationPermissionError(message: String)
    case locationAccuracyError(message: String)
    case locationError(message: String)
    case firestoreDocumentDoesNotExistError(message: String)
    case unknownError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl(let message):
            return message
        case .invalidResponse(let message):
            return message
        case .invalidData(let message):
            return message
        case .dateDecodingError(let message):
            return message
        case .invalidInput(let message):
            return message
        case .internetConnectionError(let message):
            return message
        case .cancellationError(let message):
            return message
        case .authError(let message):
            return message
        case .messagingPermissionError(let message):
            return message
        case .messagingError(let message):
            return message
        case .locationPermissionError(let message):
            return message
        case .locationError(let message):
            return message
        case .locationAccuracyError(let message):
            return message
        case .firestoreDocumentDoesNotExistError(let message):
            return message
        case .unknownError(let message):
            return message
        }
    }
    
}

// calendars
enum CalendarType: String {
    case termine
    case termineLeitungsteam
    case aktivitaetenBiberstufe
    case aktivitaetenWolfsstufe
    case aktivitaetenPfadistufe
    case aktivitaetenPiostufe
}

// snack bar types
enum SnackbarType: String {
    case error
    case info
    case success
}

// authentication state for the app
enum AuthState {
    case signedOut
    case signedInWithHitobito(user: FirebaseHitobitoUser)
    case signingIn
    case signingOut(user: FirebaseHitobitoUser)
    case error(error: PfadiSeesturmAppError)
}
extension AuthState {
    var signInButtonIsLoading: Bool {
        switch self {
        case .signingIn:
            return true
        default:
            return false
        }
    }
    var signOutButtonIsLoading: Bool {
        switch self {
        case .signingOut:
            return true
        default:
            return false
        }
    }
    var showInfoSnackbar: Bool {
        switch self {
        case .signedOut:
            return true
        default:
            return false
        }
    }
}

enum SeesturmLoadingState<Success, Failure: Error> {
    case none
    case loading
    case result(Result<Success, Failure>)
    case errorWithReload(error: PfadiSeesturmAppError)
}
extension SeesturmLoadingState {
    var userInteractionDisabled: Bool {
        switch self {
        case .loading, .result(.failure), .result(.success):
            return true
        default:
            return false
        }
    }
    var scrollingDisabled: Bool {
        switch self {
        case .loading, .errorWithReload(_), .none:
            return true
        default:
            return false
        }
    }
    var taskShouldRun: Bool {
        switch self {
        case .none, .errorWithReload(_):
            return true
        default:
            return false
        }
    }
    var infiniteScrollTaskShouldRun: Bool {
        switch self {
        case .none, .errorWithReload(_), .result(.success):
            return true
        default:
            return false
        }
    }
    var isError: Bool {
        switch self {
        case .result(.failure):
            return true
        default:
            return false
        }
    }
    var isSuccess: Bool {
        switch self {
        case .result(.success):
            return true
        default:
            return false
        }
    }
    func failureBinding(from publisher: Published<SeesturmLoadingState>.Publisher, reset: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: {
                if case .result(.failure) = self {
                    return true
                }
                return false
            },
            set: { _ in
                reset()
            }
        )
    }
    func successBinding(from publisher: Published<SeesturmLoadingState>.Publisher, reset: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: {
                if case .result(.success) = self {
                    return true
                }
                return false
            },
            set: { _ in
                reset()
            }
        )
    }
    func loadingBinding(from publisher: Published<SeesturmLoadingState>.Publisher) -> Binding<Bool> {
        Binding(
            get: {
                if case .loading = self {
                    return true
                }
                return false
            },
            set: { _ in }
        )
    }
    var errorMessage: String {
        switch self {
        case .result(.failure(let error)):
            return error.localizedDescription
        default:
            return "Ein Fehler ist aufgetreten"
        }
    }
    var successMessage: String {
        switch self {
        case .result(.success(let data)):
            if let message = data as? String {
                return message
            }
            else {
                return "Operation erfolgreich"
            }
        default:
            return ""
        }
    }
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
extension Dictionary where Value == SeesturmLoadingState<String, PfadiSeesturmAppError> {
    var hasError: Bool {
        values.contains { state in
            if case .result(.failure) = state {
                return true
            } else {
                return false
            }
        }
    }
    var hasSuccess: Bool {
        values.contains { state in
            if case .result(.success) = state {
                return true
            } else {
                return false
            }
        }
    }
    var hasLoadingElement: Bool {
        values.contains { state in
            if case .loading = state {
                return true
            } else {
                return false
            }
        }
    }
    var firstErrorMessage: String {
        for state in values {
            switch state {
            case .result(.failure(let error)):
                return error.localizedDescription
            default:
                continue
            }
        }
        return "Ein Fehler is aufgetreten"
    }
    var firstSuccessMessage: String {
        for state in values {
            switch state {
            case .result(.success(let message)):
                return message
            default:
                continue
            }
        }
        return "Operation erfolgreich"
    }
}
struct FormSection: Hashable, Identifiable {
    var id = UUID()
    var header: String
    var footer: String
}

enum SchöpflialarmResponseType {
    case unterwegs
    case heuteNicht
    case schonDa
    
    var id: Int {
        switch self {
        case .unterwegs:
            return 10
        case .heuteNicht:
            return 20
        case .schonDa:
            return 30
        }
    }
    
    init(id: Int) throws {
        switch id {
        case 10:
            self = .unterwegs
        case 20:
            self = .heuteNicht
        case 30:
            self = .schonDa
        default:
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte Reaktions-Art für Schöpflialarm.")
        }
    }
    
}
