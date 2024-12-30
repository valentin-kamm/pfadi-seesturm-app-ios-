//
//  StufenbereichView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichView: View {
    
    let stufe: SeesturmStufe
    @StateObject var viewModel: StufenbereichViewModel
    
    init(
        stufe: SeesturmStufe
    ) {
        self.stufe = stufe
        _viewModel = StateObject(wrappedValue: StufenbereichViewModel(stufe: stufe))
    }
    
    var body: some View {
        List {
            Section(header:
            Menu {
                ForEach(viewModel.stufe.allowedActionActivities, id: \.id) { activity in
                    Button(action: {
                        withAnimation {
                            viewModel.selectedFilter = activity
                        }
                    }) {
                        HStack {
                            Text(activity.nomenMehrzahl)
                            if viewModel.selectedFilter == activity {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Label(viewModel.selectedFilter.nomenMehrzahl, systemImage: viewModel.selectedFilter.icon)
                        .labelStyle(.titleAndIcon)
                    Image(systemName: "chevron.up.chevron.down")
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .foregroundStyle(viewModel.selectedFilter == .abmelden ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                .cornerRadius(16)
            }
                .padding(.vertical, 8)
                .padding(.horizontal, 0)
                .textCase(nil)
                .headerProminence(.increased)
                .frame(maxWidth: .infinity, alignment: .trailing)
            ) {}
            switch viewModel.abmeldungenLoadingState {
            case .none, .loading, .errorWithReload:
                ForEach(1..<9) { index in
                    StufenbereichAnAbmeldungenLoadingCell()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top, index == 1 ? 16 : 0)
                }
            case .result(.failure(let error)):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: error.localizedDescription,
                    asyncRetryAction: {
                        await viewModel.fetchData(isPullToRefresh: false)
                    }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding(.vertical)
            case .result(.success(let data)):
                if data.isEmpty {
                    Text("Keine An-/Abmeldungen vorhanden")
                        .padding(.horizontal)
                        .padding(.vertical, 75)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondary)
                }
                else {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, aktivitaet in
                        StufenbereichAnAbmeldungenCell(
                            event: aktivitaet,
                            stufe: stufe,
                            selectedFilter: viewModel.selectedFilter
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top, index == 0 ? 16 : 0)
                    }
                }
            }
        }
        .navigationTitle("Aktivitäten \(stufe.description)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .listStyle(.plain)
        .scrollDisabled(viewModel.abmeldungenLoadingState.scrollingDisabled)
        .task {
            if viewModel.abmeldungenLoadingState.taskShouldRun {
                await viewModel.fetchData(isPullToRefresh: false)
            }
        }
        .refreshable {
            await viewModel.fetchData(isPullToRefresh: true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: StufenbereichNavigationDestination.neueAktivität(stufe: stufe)) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: StufenbereichNavigationDestination.self) { destination in
            if case .neueAktivität(stufe: stufe) = destination {
                AktivitaetBearbeitenView(stufe: stufe, contentMode: .new)
            }
        }
    }
}

enum StufenbereichNavigationDestination: Hashable {
    case neueAktivität(stufe: SeesturmStufe)
    case abmeldungen(stufe: SeesturmStufe)
}

#Preview {
    StufenbereichView(
        stufe: .biber
    )
}
