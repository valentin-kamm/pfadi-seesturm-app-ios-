//
//  ListSectionHeader.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct ListSectionHeaderWithButton: View {
    
    var iconName: String
    var sectionTitle: String
    var showButton: Bool
    var buttonTitle: String = ""
    var buttonIconName: String = ""
    var buttonAction: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.SEESTURM_RED)
            Spacer(minLength: 16)
            Text(sectionTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2)
                .fontWeight(.bold)
            Spacer(minLength: 16)
            if showButton {
                CustomButton(
                    buttonStyle: .tertiary,
                    buttonTitle: buttonTitle,
                    buttonSystemIconName: buttonIconName,
                    buttonAction: buttonAction
                )
            }
        }
        .padding(.vertical, 8)
    }
    
}

#Preview("Ohne Button") {
    ListSectionHeaderWithButton(
        iconName: "person.2.circle.fill",
        sectionTitle: "Nächste Aktivität",
        showButton: false,
        buttonTitle: "Mehr",
        buttonIconName: "chevron.right"
    )
}
#Preview("Normaler Button") {
    ListSectionHeaderWithButton(
        iconName: "person.2.circle.fill",
        sectionTitle: "Nächste Aktivität",
        showButton: true,
        buttonTitle: "Mehr",
        buttonIconName: "chevron.right"
    )
}
