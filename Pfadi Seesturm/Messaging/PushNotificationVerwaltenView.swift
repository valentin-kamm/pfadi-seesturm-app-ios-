//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct PushNotificationVerwaltenView: View {
    
    @StateObject var viewModel = PushNotificationVerwaltenViewModel()
    private var sections: [FormSection: [PushNotificationVerwaltenToggle]] = [
        FormSection(header: "Aktuell", footer: "Erhalte eine Benachrichtigung wenn ein neuer Post veröffentlicht wurde"): [PushNotificationVerwaltenToggle(title: "Aktuell", topic: .aktuell)],
        FormSection(header: "Nächste Aktivität", footer: "Erhalte eine Benachrichtigung wenn die Infos zur nächsten Aktivität veröffentlicht wurden"): [
            PushNotificationVerwaltenToggle(title: SeesturmStufe.biber.description, topic: .biberAktivitäten),
            PushNotificationVerwaltenToggle(title: SeesturmStufe.wolf.description, topic: .wolfAktivitäten),
            PushNotificationVerwaltenToggle(title: SeesturmStufe.pfadi.description, topic: .pfadiAktivitäten),
            PushNotificationVerwaltenToggle(title: SeesturmStufe.pio.description, topic: .pioAktivitäten)
        ]
    ]
    
    var body: some View {
        Form {
            ForEach(Array(sections.keys.reversed())) { section in
                Section {
                    if let toggles = sections[section] {
                        ForEach(toggles) { toggle in
                            if let toggleLoadingState = viewModel.result[toggle.topic] {
                                switch toggleLoadingState {
                                case .loading:
                                    HStack(alignment: .center, spacing: 16) {
                                        Text(toggle.title)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                default:
                                    Toggle(
                                        toggle.title,
                                        isOn: Binding(
                                            get: { viewModel.subscribedTopics.contains(toggle.topic) },
                                            set: { newValue in
                                                Task {
                                                    await viewModel.handleToggleChange(topic: toggle.topic, isTurnedOn: newValue)
                                                }
                                            }
                                        )
                                    )
                                    .tint(Color.SEESTURM_GREEN)
                                    .disabled(
                                        viewModel.result.hasLoadingElement ||
                                        viewModel.result.hasError ||
                                        viewModel.result.hasSuccess
                                    )
                                }
                            }
                            
                        }
                    }
                } header: {
                    Text(section.header)
                } footer: {
                    Text(section.footer)
                }

            }
        }
        .navigationTitle("Push-Nachrichten")
        .navigationBarTitleDisplayMode(.inline)
        .snackbar(
            show: viewModel.failureBinding,
            type: .error,
            message: viewModel.result.firstErrorMessage,
            dismissAutomatically: true,
            allowManualDismiss: true,
            onDismiss: {}
        )
        .snackbar(
            show: viewModel.successBinding,
            type: .success,
            message: viewModel.result.firstSuccessMessage,
            dismissAutomatically: true,
            allowManualDismiss: true,
            onDismiss: {}
        )
        .alert("Push-Nachrichten nicht aktiviert", isPresented: $viewModel.showSettingsAlert) {
            Button("Einstellungen") {
                FCMManager.shared.goToNotificationSettings()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
        }
    }
    
}

struct PushNotificationVerwaltenToggle: Identifiable {
    var id = UUID()
    var title: String
    var topic: SeesturmNotificationTopic
}

#Preview {
    PushNotificationVerwaltenView()
}
