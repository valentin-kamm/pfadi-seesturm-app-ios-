//
//  AccountView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $appState.tabNavigationPaths[AppMainTab.leiterbereich.id]) {
            ScrollView {
                switch appState.authState {
                case .signedOut, .signingIn(.button):
                    LoggedOutView(buttonIsLoading: appState.authState.signInButtonIsLoading)
                case .signingIn(.fullScreen):
                    SigningInLoadingView()
                case .error(let error):
                    AuthErrorView(error: error)
                case .signingOut:
                    SigningOutLoadingView()
                case .signedInWithHitobito:
                    Leiterbereich()
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .snackbar(show: .constant(appState.authState.showInfoSnackbar), type: .info, message: "Die Anmeldung ist nur fürs Leitungsteam der Pfadi Seesturm möglich", dismissAutomatically: false, allowManualDismiss: false, onDismiss: {})
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
}
