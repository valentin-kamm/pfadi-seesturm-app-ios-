//
//  AktivitaetAnAbmeldenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//

import SwiftUI

struct AktivitaetAnAbmeldenView: View {
    
    @StateObject var viewModel = AktivitaetAnAbmeldenViewModel()
    var aktivitaet: TransformedCalendarEventResponse
    var stufe: SeesturmStufe
    @State var selectedContentMode: AktivitaetAktion
    @State var navigateToGespeichertePersonen = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Vorname", text: $viewModel.vorname)
                    }
                    HStack {
                        Image(systemName: "person.text.rectangle.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Nachname", text: $viewModel.nachname)
                    }
                    HStack {
                        Image(systemName: "face.smiling")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextField("Pfadiname (optional)", text: $viewModel.pfadiname)
                    }
                }
                Section(header: Text("Bemerkung (optional)")) {
                    HStack {
                        Image(systemName: "text.bubble")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        TextEditor(text: $viewModel.bemerkung)
                            .frame(height: 75)
                    }
                }
                Section {
                    Picker("An-/Abmeldung", selection: $selectedContentMode) {
                        ForEach(stufe.allowedActionActivities, id: \.self) { aktion in
                            Label(aktion.nomen, systemImage: aktion.icon)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(selectedContentMode == .anmelden ? Color.SEESTURM_GREEN : Color.SEESTURM_RED)
                }
                Section {
                    CustomButton(
                        buttonStyle: .primary,
                        buttonTitle: "\(selectedContentMode.nomen) senden",
                        isLoading: viewModel.savingResult.loadingBinding(from: viewModel.$savingResult),
                        asyncButtonAction: {
                            await viewModel.saveAnAbmeldung(eventId: aktivitaet.id, selectedContentMode: selectedContentMode, stufe: stufe)
                        }
                    )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .snackbar(
                show: viewModel.savingResult.failureBinding(from: viewModel.$savingResult, reset: {
                    viewModel.savingResult = .none
                }),
                type: .error,
                message: viewModel.savingResult.errorMessage,
                dismissAutomatically: true,
                allowManualDismiss: true,
                onDismiss: {}
            )
            .snackbar(
                show: viewModel.savingResult.successBinding(from: viewModel.$savingResult, reset: {
                    viewModel.savingResult = .none
                }),
                type: .success,
                message: viewModel.savingResult.successMessage,
                dismissAutomatically: true,
                allowManualDismiss: true,
                onDismiss: {}
            )
            .navigationDestination(isPresented: $navigateToGespeichertePersonen) {
                GespeichertePersonenView()
            }
            .navigationTitle("Aktivität vom \(aktivitaet.startDay) \(aktivitaet.startMonth)")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(content: {
                        if !viewModel.personen.isEmpty {
                            Section("Gespeicherte Personen") {
                                ForEach(viewModel.personen, id: \.id) { person in
                                    Button(action: {
                                        withAnimation {
                                            viewModel.vorname = person.vorname
                                            viewModel.nachname = person.nachname
                                            viewModel.pfadiname = person.pfadiname ?? ""
                                        }
                                    }, label: {
                                        if let pfadiname = person.pfadiname {
                                            Text("\(person.vorname) \(person.nachname) / \(pfadiname)")
                                        }
                                        else {
                                            Text("\(person.vorname) \(person.nachname)")
                                        }
                                    })
                                }
                            }
                        }
                        Section {
                            Button(action: {
                                self.navigateToGespeichertePersonen = true
                            }, label: {
                                Text("Person hinzufügen")
                            })
                        }
                    }, label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    })
                }
            }
            .onAppear {
                viewModel.updateGespeichertePersonen()
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview("An- und abmelden") {
    AktivitaetAnAbmeldenView(
        aktivitaet: TermineCardViewPreviewExtension().oneDayEventData(),
        stufe: .wolf,
        selectedContentMode: .anmelden)
}
