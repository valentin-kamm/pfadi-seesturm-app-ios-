//
//  AktivitaetAnAbmeldenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//

import SwiftUI

@MainActor
class AktivitaetAnAbmeldenViewModel: ObservableObject {
    
    @Published var vorname = ""
    @Published var nachname = ""
    @Published var pfadiname = ""
    @Published var bemerkung = ""
    @Published var personen: [GespeichertePerson] = []
    @Published var savingResult: SeesturmLoadingState<String, PfadiSeesturmAppError> = .none
    
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
    
    // save An-/Abmeldung
    func saveAnAbmeldung(eventId: String, selectedContentMode: AktivitaetAktion, stufe: SeesturmStufe) async {
        do {
            let data = constructAnAbmeldung(eventId: eventId, selectedContentMode: selectedContentMode, stufe: stufe)
            try validateAnAbmeldung(data: data)
            self.savingResult = .loading
            try await FirestoreManager.shared.saveAnAbmeldung(input: data)
            withAnimation {
                self.savingResult = .result(.success("Die \(selectedContentMode.nomen) wurde erfolgreich gespeichert."))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                self.savingResult = .result(.failure(pfadiSeesturmError))
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.savingResult = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    
    // construct an-/abmeldung
    private func constructAnAbmeldung(eventId: String, selectedContentMode: AktivitaetAktion, stufe: SeesturmStufe) -> AktivitaetAnAbmeldung {
        return AktivitaetAnAbmeldung(
            eventId: eventId.trimmingCharacters(in: .whitespacesAndNewlines),
            vorname: vorname.trimmingCharacters(in: .whitespacesAndNewlines),
            nachname: nachname.trimmingCharacters(in: .whitespacesAndNewlines),
            pfadiname: pfadiname.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : pfadiname.trimmingCharacters(in: .whitespacesAndNewlines),
            bemerkung: bemerkung.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : bemerkung.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedContentMode.id,
            stufenId: stufe.id
        )
    }
    
    // validation of an-/abmeldung
    private func validateAnAbmeldung(data: AktivitaetAnAbmeldung) throws {
        if data.vorname == "" || data.nachname == "" {
            throw PfadiSeesturmAppError.invalidInput(message: "An-/Abmeldung kann nicht gespeichert werden. Die Daten sind unvollständig.")
        }
        if data.eventId == "" {
            throw PfadiSeesturmAppError.invalidInput(message: "An-/Abmeldung kann nicht gespeichert werden. Die Aktivität ist unbekannt.")
        }
    }
}
