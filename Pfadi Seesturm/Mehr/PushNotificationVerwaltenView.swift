//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct PushNotificationVerwaltenView: View {
    
    @AppStorage("isSubscribedToAktuellFCMTopic_V2") var isSubscribedToAktuellFCMTopic: Bool = true
    
    @AppStorage("isSubscribedToBiberstufeFCMTopic_V2") var isSubscribedToBiberstufeFCMTopic: Bool = true
    @AppStorage("isSubscribedToWolfsstufeFCMTopic_V2") var isSubscribedToWolfsstufeFCMTopic: Bool = true
    @AppStorage("isSubscribedToPfadistufeFCMTopic_V2") var isSubscribedToPfadistufeFCMTopic: Bool = true
    @AppStorage("isSubscribedToPiostufeFCMTopic_V2") var isSubscribedToPiostufeFCMTopic: Bool = true
    
    var body: some View {
        Form {
            Section(header: Text("Aktuell"), footer: Text("Erhalte eine Benachrichtigung wenn ein neuer Post veröffentlicht wurde")) {
                Toggle("Aktuell", isOn: $isSubscribedToAktuellFCMTopic)
                    .tint(Color.SEESTURM_GREEN)
            }
            Section(header: Text("Nächste Aktivität"), footer: Text("Erhalte eine Benachrichtigung wenn die Infos zur nächsten Aktivität veröffentlicht wurden")) {
                Toggle(SeesturmStufe.biber.description, isOn: $isSubscribedToBiberstufeFCMTopic)
                    .tint(Color.SEESTURM_GREEN)
                Toggle(SeesturmStufe.wolf.description, isOn: $isSubscribedToWolfsstufeFCMTopic)
                    .tint(Color.SEESTURM_GREEN)
                Toggle(SeesturmStufe.pfadi.description, isOn: $isSubscribedToPfadistufeFCMTopic)
                    .tint(Color.SEESTURM_GREEN)
                Toggle(SeesturmStufe.pio.description, isOn: $isSubscribedToPiostufeFCMTopic)
                    .tint(Color.SEESTURM_GREEN)
            }
        }
        .navigationTitle("Push-Nachrichten")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PushNotificationVerwaltenView()
}
