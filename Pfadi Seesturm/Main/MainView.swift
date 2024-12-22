//
//  ContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI

struct MainView : View {
    
    // view model for navigation
    @EnvironmentObject var appState: AppState
    
    // selected appearance
    @AppStorage("theme") var selectedTheme: String = "system"
        
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
            .tabItem {
                VStack {
                    Image("LogoTabbar")
                        .renderingMode(appState.selectedTab == .home ? .original : .template)
                    Text("Home")
                }
            }
            .tag(AppMainTab.home)
            .toolbarBackground(.bar, for: .tabBar)
            LazyView(AktuellView())
            .tabItem {
                Label("Aktuell", systemImage: "newspaper")
            }
            .tag(AppMainTab.aktuell)
            .toolbarBackground(.bar, for: .tabBar)
            TermineView()
            .tabItem {
                Label("Anlässe", systemImage: "calendar")
            }
            .tag(AppMainTab.anlässe)
            .toolbarBackground(.bar, for: .tabBar)
            MehrView()
            .tabItem {
                Label("Mehr", systemImage: "ellipsis.rectangle")
            }
            .tag(AppMainTab.mehr)
            .toolbarBackground(.bar, for: .tabBar)
            AccountView()
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(AppMainTab.leiterbereich)
            .toolbarBackground(.bar, for: .tabBar)
        }
        .accentColor(Color.SEESTURM_GREEN)
        // there is a bug in iOS 18.0
        // -> always return nil for this case
        .preferredColorScheme(
            !(ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 18 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 0) ?
            getAppearance(selectedTheme: selectedTheme)
            : .none
        )
    }
    
    // function to return the appearance depending on the app storage value
    private func getAppearance(selectedTheme: String) -> ColorScheme? {
        switch selectedTheme {
        case "hell":
            return .light
        case "dunkel":
            return .dark
        default:
            return .none
        }
    }
    
}
