//
//  AktivitätBearbeitenViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

@MainActor
class AktivitaetBearbeitenViewModel: ObservableObject {
    
    @Published var html: String = ""
    @Published var stufe: SeesturmStufe
    @Published var startDateTime: Date
    @Published var endDateTime: Date
    @Published var treffpunkt: String = "Pfadiheim"
    @Published var sendPushNotification: Bool = true
    
    @Published var publishEventLoadingState: SeesturmLoadingState<String, PfadiSeesturmAppError> = .none
    
    init(
        stufe: SeesturmStufe,
        startDateTime: Date = Date(),
        endDateTime: Date = Date()
    ) {
        self.stufe = stufe
        self.startDateTime = DateTimeUtil.shared.nextSaturday(at: 14)
        self.endDateTime = DateTimeUtil.shared.nextSaturday(at: 16)
    }
    
    // function to save activity to google calendar
    func publishEvent() async {
        
    }
    
}
