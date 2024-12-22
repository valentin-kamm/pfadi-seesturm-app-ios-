//
//  GespeichertePersonHinzufügenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI

struct GespeichertePersonHinzufuegenView: View {
    
    @ObservedObject var viewModel: GespeichertePersonenViewModel
    
    @State private var vorname = ""
    @State private var nachname = ""
    @State private var pfadiname = ""
        
    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("Speichere die Angaben einer Person, die du häufig von Aktivitäten abmeldest.")) {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Vorname", text: $vorname)
                    }
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Nachname", text: $nachname)
                    }
                    HStack {
                        Image(systemName: "face.smiling")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Pfadiname (optional)", text: $pfadiname)
                    }
                }
                Section {
                    CustomButton(
                        buttonStyle: .primary,
                        buttonTitle: "Speichern",
                        buttonAction: {
                            onInsertButtonClick()
                        }
                    )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Person hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
            .snackbar(
                show: $viewModel.savingError.mappedToBool(),
                type: .error,
                message: viewModel.savingError?.localizedDescription ?? "Ein Fehler ist aufgetreten",
                dismissAutomatically: true,
                allowManualDismiss: true,
                onDismiss: {}
            )
        }
    }
        
    private func onInsertButtonClick() {
        let person = GespeichertePerson(
            id: UUID(),
            vorname: vorname.trimmingCharacters(in: .whitespacesAndNewlines),
            nachname: nachname.trimmingCharacters(in: .whitespacesAndNewlines),
            pfadiname: pfadiname.trimmingCharacters(in: .whitespacesAndNewlines) != "" ? pfadiname.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        )
        viewModel.savePerson(person: person)
    }
    
}
