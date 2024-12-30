//
//  CardErrorView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct CardErrorView: View {
    
    // parameters passed to this view
    let errorTitle: String
    let errorDescription: String
    let retryAction: (() -> Void)?
    let asyncRetryAction: (() async throws -> Void)?
    
    init(
        errorTitle: String,
        errorDescription: String,
        retryAction: (() -> Void)? = nil,
        asyncRetryAction: (() async throws -> Void)? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorDescription = errorDescription
        self.retryAction = retryAction
        self.asyncRetryAction = asyncRetryAction
    }
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.SEESTURM_GREEN)
                    .padding(.top, 24)
                Text(errorTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text(errorDescription)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, (asyncRetryAction != nil || retryAction != nil) ? 0 : 24)
                if asyncRetryAction != nil || retryAction != nil {
                    CustomButton(
                        buttonStyle: .tertiary(),
                        buttonTitle: "Erneut versuchen",
                        buttonAction: retryAction,
                        asyncButtonAction: asyncRetryAction
                    )
                    .padding(.bottom, 24)
                }
            }.padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CardErrorView(
        errorTitle: "Ein Fehler ist aufgetreten",
        errorDescription: "Die vom Server übermittelten Daten sind ungültig.",
        retryAction: {
            print("Retry button clicked.")
        }
    )
}
