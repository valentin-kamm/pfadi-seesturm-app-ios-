//
//  Pfadi_SeesturmApp.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI

@main
struct Pfadi_SeesturmApp: App {
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    // set color for page indicators
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .secondaryLabel
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                // open any links in SFSafariViewController
                .handleOpenURLInApp()
                // supply navigation state from viewModel
                .environmentObject(appState)
                // handle universal links
                .onOpenURL { url in
                    appState.navigateToFromUniversalLink(url: url)
                }
        }
    }
}
