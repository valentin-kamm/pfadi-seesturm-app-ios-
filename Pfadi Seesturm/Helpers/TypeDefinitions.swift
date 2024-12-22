//
//  TypeDefinitions.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

// loading state
enum SeesturmLoadingState {
    case none
    case success
    case error(error: PfadiSeesturmAppError)
    case loading
    case errorWithReload(error: PfadiSeesturmAppError)
}
extension SeesturmLoadingState {
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
        case .none, .errorWithReload(_), .success:
            return true
        default:
            return false
        }
    }
    var isError: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
}

enum SeesturmNaechsteAktivitaetHomeLoadingState {
    case none
    case success(aktivitaet: TransformedCalendarEventResponse?)
    case error(error: PfadiSeesturmAppError)
    case loading
    case errorWithReload(error: PfadiSeesturmAppError)
}
extension SeesturmNaechsteAktivitaetHomeLoadingState {
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
        case .none, .errorWithReload(_), .success:
            return true
        default:
            return false
        }
    }
}

// stufen der pfadi seesturm
enum SeesturmStufe: Codable, Comparable, Hashable {
    case biber
    case wolf
    case pfadi
    case pio
    
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
    
    var allowedActionActivities: [AktivitaetAktionen] {
        switch self {
        case .biber:
            return [.abmelden, .anmelden]
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
enum AktivitaetAktionen: CaseIterable, Identifiable {
    case anmelden
    case abmelden
    
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
    case tertiary
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
    case signedInWithHitobito
    case signingIn(loadingType: AuthLoadingType)
    case signingOut
    case error(error: PfadiSeesturmAppError)
}
enum AuthLoadingType {
    case button
    case fullScreen
}
extension AuthState {
    var signInButtonIsLoading: Bool {
        switch self {
        case .signingIn(.button):
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
