//
//  AppDelegate.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//
import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureFirebase()
        configureAppCheck()
        return true
    }
    
    // function that sets up AppCheck
    private func configureAppCheck() {
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(SeesturmAppAttestDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(SeesturmAppAttestProviderFactory())
        #endif
    }
    
    // function to set up firebase depending on debug or release
    private func configureFirebase() {
        let fileName: String
        #if DEBUG
        fileName = "GoogleService-Info-Debug"
        #else
        fileName = "GoogleService-Info-Release"
        #endif
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            fatalError("Could not include Firebase in the Project.")
        }
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            fatalError("Could not include Firebase in the Project.")
        }
        FirebaseApp.configure(options: options)
    }
    
}
