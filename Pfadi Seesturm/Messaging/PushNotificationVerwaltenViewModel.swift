//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import SwiftUI

@MainActor
class PushNotificationVerwaltenViewModel: ObservableObject {
    
    @Published var showSettingsAlert: Bool = false
    @Published var currentTopic: SeesturmNotificationTopic? = nil
    @Published var subscribedTopics: Set<SeesturmNotificationTopic> = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    @Published var result: [SeesturmNotificationTopic: SeesturmLoadingState<String, PfadiSeesturmAppError>] = [
        .aktuell: .none,
        .biberAktivitäten: .none,
        .wolfAktivitäten: .none,
        .pfadiAktivitäten: .none,
        .pioAktivitäten: .none
    ]
    var failureBinding: Binding<Bool> {
        Binding(
            get: {
                return self.result.hasError
            },
            set: { newValue in
                for key in self.result.keys {
                    if self.result[key] != nil && !newValue, case .result(.failure) = self.result[key] {
                        withAnimation {
                            self.result[key]! = .none
                        }
                    }
                }
            }
        )
    }
    var successBinding: Binding<Bool> {
        Binding(
            get: {
                return self.result.hasSuccess
            },
            set: { newValue in
                for key in self.result.keys {
                    if self.result[key] != nil && !newValue, case .result(.success) = self.result[key] {
                        withAnimation {
                            self.result[key]! = .none
                        }
                    }
                }
            }
        )
    }
    let userDefaults = UserDefaults.standard
    let fcmManager = FCMManager.shared
    
    init() {
        loadFromUserDefaults()
    }
    
    // function to handle toggle changes
    func handleToggleChange(topic: SeesturmNotificationTopic, isTurnedOn: Bool) async {
        if isTurnedOn {
            await subscribe(to: topic)
        }
        else {
            await unsubscribe(from: topic)
        }
    }
    
    // functions to subscribe/unsubscribe from topics
    private func subscribe(to topic: SeesturmNotificationTopic) async {
        do {
            result[topic] = .loading
            try await fcmManager.requestOrCheckNotificationPermission()
            try await fcmManager.subscribe(to: topic)
            withAnimation {
                subscribedTopics.insert(topic)
                result[topic] = .result(.success("Erfolgreich angemeldet"))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .messagingPermissionError = pfadiSeesturmError {
                withAnimation {
                    showSettingsAlert = true
                    result[topic] = SeesturmLoadingState<String, PfadiSeesturmAppError>.none
                }
            }
            else {
                withAnimation {
                    result[topic] = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                result[topic] = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    private func unsubscribe(from topic: SeesturmNotificationTopic) async {
        do {
            withAnimation {
                result[topic] = .loading
            }
            try await fcmManager.unsubscribe(from: topic)
            withAnimation {
                subscribedTopics.remove(topic)
                result[topic] = .result(.success("Erfolgreich abgemeldet"))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                result[topic] = .result(.failure(pfadiSeesturmError))
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                result[topic] = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    
    // function to save the topics that the user has subscribed to
    private func saveToUserDefaults() {
        userDefaults.set(Array(subscribedTopics), forKey: "subscribedFCMTopics_v2")
    }
    
    // function to read the topics that the user has subscribed to
    private func loadFromUserDefaults() {
        if let savedTopics = userDefaults.array(forKey: "subscribedFCMTopics_v2") as? [SeesturmNotificationTopic] {
            subscribedTopics = Set(savedTopics)
        }
    }
    
}
