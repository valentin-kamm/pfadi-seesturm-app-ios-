//
//  StufenbereichAnAbmeldungenLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungenLoadingCell: View {
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .leading, spacing: 16) {
                Text(Constants.PLACEHOLDER_TEXT)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
                Label("Abmeldungen", systemImage: AktivitaetAktion.abmelden.icon)
                    .font(.caption)
                    .opacity(0)
                    .lineLimit(1)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemGray5))
                    )
                    .labelStyle(.titleAndIcon)
                    .customLoadingBlinking()
                CustomCardView(shadowColor: .clear, backgroundColor: Color(UIColor.systemGray5)) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .lineLimit(5)
                        .font(.caption)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    StufenbereichAnAbmeldungenLoadingCell()
}
