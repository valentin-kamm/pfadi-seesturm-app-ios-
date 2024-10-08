//
//  ContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI

struct MainView : View {
    // The tab that is selected
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab für Home
            NavigationView {
                HomeView()
                    .navigationTitle("Home")
            }
            .tabItem {
                VStack {
                    if selectedTab == 0 {
                        Image("LogoTabbar")
                            .renderingMode(.original)
                    }
                    else {
                        Image("LogoTabbar")
                            .renderingMode(.template)
                    }
                    Text("Home")
                }
            }
            .tag(0)
            // Tab für Aktuell
            NavigationView {
                AktuellView()
                    .navigationTitle("Aktuell")
            }
            .tabItem {
                Label("Aktuell", systemImage: "newspaper")
            }
            .tag(1)
            // Tab für Termine
            NavigationView {
                TermineView()
                    .navigationTitle("Termine")
            }
            .tabItem {
                Label("Termine", systemImage: "calendar")
            }
            .tag(2)
            // Tab für Mehr
            NavigationView {
                MehrView()
                    .navigationTitle("Mehr")
            }
            .tabItem {
                Label("Mehr", systemImage: "ellipsis.rectangle")
            }
            .tag(3)
            // Tab für Anmeldung
            NavigationView {
                AccountView()
                    .navigationTitle("Account")
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(4)        }
        .accentColor(Constants.SEESTURM_GREEN)
    }
}

#Preview {
    MainView()
}
