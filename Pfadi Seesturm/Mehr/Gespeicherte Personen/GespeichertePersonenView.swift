//
//  GespeichertePersonenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct GespeichertePersonenView: View {
    
    @StateObject private var viewModel: GespeichertePersonenViewModel = GespeichertePersonenViewModel()
    
    var body: some View {
        AnyView(
            List {
                if let error = viewModel.readingError {
                    CardErrorView(
                        errorTitle: "Ein Fehler ist aufgetreten",
                        errorDescription: error.localizedDescription
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical)
                }
                else if viewModel.personen.isEmpty {
                    CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "person.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                                .padding(.top, 24)
                            Text("Keine Personen gespeichert")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Text("Füge die Angaben von Personen hinzu, die du of von Aktivitäten abmeldest. So musst du sie nicht jedes Mal neu eintragen.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 8)
                            CustomButton(
                                buttonStyle: .primary,
                                buttonTitle: "Person hinzufügen",
                                buttonSystemIconName: "person.badge.plus",
                                buttonAction: {
                                    viewModel.showInsertSheet = true
                                }
                            )
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding()
                }
                else {
                    ForEach(Array(viewModel.personen.enumerated()), id: \.element.id) { index, person in
                        if let pfadiname = person.pfadiname {
                            Text("\(person.vorname) \(person.nachname) / \(pfadiname)")
                        }
                        else {
                            Text("\(person.vorname) \(person.nachname)")
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deletePerson(at: indexSet)
                    }
                }
            }
                .myListStyle(isListPlain: (viewModel.readingError != nil || viewModel.personen.isEmpty))
                .background(Color.customBackground)
                .sheet(isPresented: $viewModel.showInsertSheet, content: {
                    GespeichertePersonHinzufuegenView(viewModel: viewModel)
                })
                .toolbar {
                    if viewModel.readingError == nil && !viewModel.personen.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            EditButton()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.showInsertSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .snackbar(
                    show: $viewModel.deletingError.mappedToBool(),
                    type: .error,
                    message: viewModel.deletingError?.localizedDescription ?? "Person konnte nicht gelöscht werden. Unbekannter Fehler.",
                    dismissAutomatically: true,
                    allowManualDismiss: true,
                    onDismiss: {}
                )
        )
    }
}

#Preview {
    GespeichertePersonenView()
}
