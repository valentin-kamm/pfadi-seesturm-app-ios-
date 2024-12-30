//
//  LoggedOutView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI

struct LoggedOutView: View {
    
    @EnvironmentObject var appState: AppState
        
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Image("SeesturmLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Login")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                Text("Melde dich mit MiData an um fortzufahren.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                CustomButton(
                    buttonStyle: .primary,
                    buttonTitle: "Login mit MiData",
                    buttonCustomIconName: "midataLogo",
                    isLoading: .constant(appState.authState.signInButtonIsLoading),
                    asyncButtonAction: {
                        await appState.authenticateWithHitobito()
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
    LoggedOutView()
}
