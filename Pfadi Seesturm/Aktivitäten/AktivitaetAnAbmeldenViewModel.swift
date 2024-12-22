//
//  AktivitaetAnAbmeldenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//

import SwiftUI

@MainActor
class AktivitaetAnAbmeldenViewModel: ObservableObject {
    
    @Published var personen: [GespeichertePerson] = []
    
    func updateGespeichertePersonen() {
        let data = UserDefaults().data(forKey: "gespeichertePersonen_v2") ?? Data()
        guard !data.isEmpty else {
            withAnimation {
                self.personen = []
            }
            return
        }
        if let pers = try? JSONDecoder().decode([GespeichertePerson].self, from: data) {
            let personenSorted = pers.sorted {
                $0.vorname < $1.vorname
            }
            withAnimation {
                self.personen = personenSorted
            }
        }
        else {
            withAnimation {
                self.personen = []
            }
        }
    }
}
