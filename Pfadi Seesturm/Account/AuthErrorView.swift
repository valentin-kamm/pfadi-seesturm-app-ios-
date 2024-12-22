//
//  AuthErrorView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import SwiftUI

struct AuthErrorView: View {
    
    @EnvironmentObject var appState: AppState
    let error: PfadiSeesturmAppError
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .foregroundStyle(Color.SEESTURM_RED)
                Text("Die Anmeldung konnte nicht durchgeführt werden")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Text(error.localizedDescription)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                CustomButton(
                    buttonStyle: .primary,
                    buttonTitle: "Zurück",
                    buttonAction: {
                        appState.changeAuthState(newAuthState: .signedOut)
                    }
                )
            }
            .padding()
            .padding(.vertical, 8)
        }
        .padding()
    }
}

#Preview {
    AuthErrorView(error: PfadiSeesturmAppError.authError(message: "Fehler beim Anmelden"))
        .environmentObject(AppState())
}
