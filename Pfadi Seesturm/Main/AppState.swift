//
//  AppNavigationState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.12.2024.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: AppMainTab = .home
    @Published var tabNavigationPaths: [NavigationPath] = [
        NavigationPath(),
        NavigationPath(),
        NavigationPath(),
        NavigationPath(),
        NavigationPath()
    ]
    @Published var authState: AuthState = .signedOut
        
    // function to authenticate
    func authenticateWithHitobito() async {
        await HitobitoAuthService.shared.authenticate { newAuthState in
            self.changeAuthState(newAuthState: newAuthState)
        }
    }
    
    // function to change auth state
    func changeAuthState(newAuthState: AuthState) {
        Task { @MainActor in
            withAnimation {
                self.authState = newAuthState
            }
        }
    }
    
    // function to navigate to a specific screen from a universal link
    func navigateToFromUniversalLink(url: URL) {
        if let (tab, path) = UniversalLinksHandler.shared.getNavigationDestinationFromUniversalLink(url: url) {
            navigateTo(tab: tab, path: path)
        }
    }
    
    // function to navigate to a specific screen
    private func navigateTo(tab: AppMainTab, path: NavigationPath) {
        withAnimation {
            self.selectedTab = tab
        }
        withAnimation {
            self.tabNavigationPaths[tab.id] = path
        }
    }
}
