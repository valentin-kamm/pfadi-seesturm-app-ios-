//
//  ListSectionHeader.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct ListSectionHeaderWithButton: View {
    
    var headerType: ListSectionHeaderType
    var sectionTitle: String
    var iconName: String
    
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
            switch headerType {
            case .blank:
                EmptyView()
            case .button(let buttonTitle, let buttonIconName, let buttonAction):
                CustomButton(
                    buttonStyle: .tertiary(),
                    buttonTitle: buttonTitle,
                    buttonSystemIconName: buttonIconName,
                    buttonAction: buttonAction
                )
            }
        }
        .padding(.vertical, 8)
    }
}

enum ListSectionHeaderType {
    case blank
    case button(buttonTitle: String? = nil, buttonIconName: String? = nil, buttonAction: (() -> Void)? = nil)
}

#Preview("Ohne Button") {
    ListSectionHeaderWithButton(
        headerType: .blank,
        sectionTitle: "Nächste Aktivität",
        iconName: "person.2.circle.fill"
    )
}
#Preview("Mit Button") {
    ListSectionHeaderWithButton(
        headerType: .button(
            buttonTitle: "Mehr",
            buttonIconName: "chevron.right",
            buttonAction: {}
        ),
        sectionTitle: "Nächste Aktivität",
        iconName: "person.2.circle.fill"
    )
}
