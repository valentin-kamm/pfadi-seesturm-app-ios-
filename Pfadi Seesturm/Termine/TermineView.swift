//
//  TermineView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct TermineView: View {
    
    var type: TermineViewInputType
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch type {
        case .mainTab:
            NavigationStack(path: $appState.tabNavigationPaths[AppMainTab.anlässe.id]) {
                TermineContentView(type: type)
            }
            .tint(Color.SEESTURM_GREEN)
        case .leiterbereich:
            TermineContentView(type: type)
        }
        
    }
}

enum TermineViewInputType {
    case mainTab
    case leiterbereich
}

#Preview {
    TermineView(type: .mainTab)
        .environmentObject(AppState())
}
