//
//  LeiterbereichStufeCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct LeiterbereichStufeCardView: View {
    
    var width: CGFloat
    var stufe: SeesturmStufe
    var contentMode: LeiterbereichStufeCardViewContentMode
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            switch contentMode {
            case .simple:
                ZStack(alignment: .trailing) {
                    VStack(alignment: .center, spacing: 8) {
                        stufe.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text(stufe.description)
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            case .expanded(let navigateTo):
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .center, spacing: 8) {
                        stufe.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text(stufe.description)
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .layoutPriority(1)
                    VStack(alignment: .center, spacing: 8) {
                        CustomButton(
                            buttonStyle: .tertiary(color: .SEESTURM_RED),
                            buttonTitle: "Neue Aktivität",
                            buttonAction: {
                                navigateTo(.neueAktivität(stufe: stufe))
                            }
                        )
                        CustomButton(
                            buttonStyle: .tertiary(),
                            buttonTitle: "Abmeldungen",
                            buttonAction: {
                                navigateTo(.abmeldungen(stufe: stufe))
                            }
                        )
                    }
                    .layoutPriority(0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.secondary)
                        .layoutPriority(1)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(width: width)
        .padding(.vertical)
    }
}

enum LeiterbereichStufeCardViewContentMode {
    case expanded(navigateTo: (StufenbereichNavigationDestination) -> Void)
    case simple
}

#Preview("Simple") {
    LeiterbereichStufeCardView(
        width: 200,
        stufe: .pio,
        contentMode: .simple
    )
}
#Preview("Expanded") {
    LeiterbereichStufeCardView(
        width: 350,
        stufe: .pio,
        contentMode: .expanded(navigateTo: { _ in})
    )
}
