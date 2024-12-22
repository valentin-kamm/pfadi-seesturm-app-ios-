//
//  GespeichertePersonenViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 11.11.2024.
//

import SwiftUI


@MainActor
class GespeichertePersonenViewModel: ObservableObject {
    
    @Published var personen: [GespeichertePerson] = []
    @Published var readingError: PfadiSeesturmAppError? = nil
    @Published var savingError: PfadiSeesturmAppError? = nil
    @Published var deletingError: PfadiSeesturmAppError? = nil
    @Published var showInsertSheet: Bool = false
    @Published var listStyle: any ListStyle = .plain
    
    let userDefaults = UserDefaults.standard
    let userDefaultsKey = "gespeichertePersonen_v2"
    
    init() {
        updateGespeichertePersonen()
    }
    
    // function to update the published variable
    func updateGespeichertePersonen() {
        withAnimation {
            readingError = nil
        }
        do {
            let personen = try readGespeichertePersonen()
            let personenSorted = personen.sorted {
                $0.vorname < $1.vorname
            }
            withAnimation {
                self.personen = personenSorted
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                self.readingError = pfadiSeesturmError
            }
        }
        catch {
            withAnimation {
                self.readingError = PfadiSeesturmAppError.unknownError(message: "Unbekannter Fehler: \(error.localizedDescription)")
            }
        }
    }
    
    // functions to delete a person
    func deletePerson(at indexSet: IndexSet) {
        withAnimation {
            self.deletingError = nil
        }
        do {
            var oldArray = try readGespeichertePersonen()
            oldArray.remove(atOffsets: indexSet)
            let sortedPersons = oldArray.sorted {
                $0.vorname < $1.vorname
            }
            let dataToSave = try encodePersonArray(persons: sortedPersons)
            userDefaults.set(dataToSave, forKey: userDefaultsKey)
            withAnimation {
                self.personen = sortedPersons
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                self.deletingError = pfadiSeesturmError
            }
        }
        catch {
            withAnimation {
                self.deletingError = PfadiSeesturmAppError.unknownError(message: "Unbekannter Fehler: \(error.localizedDescription)")
            }
        }
    }
    
    // function to read saved persons
    func readGespeichertePersonen() throws -> [GespeichertePerson] {
        let data = userDefaults.data(forKey: userDefaultsKey) ?? Data()
        guard !data.isEmpty else {
            return []
        }
        return try decodePersonArray(data: data)
    }
    
    // function to save a new person
    func savePerson(person: GespeichertePerson) {
        withAnimation {
            self.savingError = nil
        }
        do {
            try validateInput(person: person)
            var existingPersons = try readGespeichertePersonen()
            existingPersons.append(person)
            let sortedPersons = existingPersons.sorted {
                $0.vorname < $1.vorname
            }
            let dataToSave = try encodePersonArray(persons: sortedPersons)
            userDefaults.set(dataToSave, forKey: userDefaultsKey)
            withAnimation {
                self.personen = sortedPersons
            }
            showInsertSheet = false
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            withAnimation {
                self.savingError = pfadiSeesturmError
            }
        }
        catch {
            withAnimation {
                self.savingError = PfadiSeesturmAppError.unknownError(message: "Unbekannter Fehler: \(error.localizedDescription)")
            }
        }
    }
    
    // function to validate the input when saving a new person
    private func validateInput(person: GespeichertePerson) throws {
        if person.vorname == "" || person.nachname == "" {
            throw PfadiSeesturmAppError.invalidInput(message: "Person kann nicht gespeichert werden. Die Daten sind unvollständig.")
        }
    }
    
    // functions to encode and decode the array of custom objects to data
    private func encodePersonArray(persons: [GespeichertePerson]) throws -> Data {
        do {
            return try JSONEncoder().encode(persons)
        }
        catch {
            throw PfadiSeesturmAppError.invalidInput(message: "Beim Speichern der Personen ist ein Fehler aufgetreten.")
        }
    }
    private func decodePersonArray(data: Data) throws -> [GespeichertePerson] {
        do {
            return try JSONDecoder().decode([GespeichertePerson].self, from: data)
        }
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Beim Lesen der Personen ist ein Fehler aufgetreten.")
        }
    }
    
}
