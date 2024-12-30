//
//  LeitungsteamView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

struct LeitungsteamView: View {
    
    @StateObject var viewModel: LeitungsteamViewModel = LeitungsteamViewModel()
    @State var selectedStufe: String = ""
    @Environment(\.scenePhase) private var scenePhase
    let passedStufe: String
    
    var body: some View {
        
        List {
            switch viewModel.loadingState {
            case .none, .loading, .errorWithReload(_):
                Section(header: Text("Abteilungsleitung")
                    .frame(height: 45, alignment: .leading)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                ) {
                    ForEach(1..<10) { index in
                        LeitungsteamLoadingCell()
                            .padding(.bottom)
                            .padding(.top, index == 1 ? 16 : 0)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }
            case .result(.failure(let error)):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: error.localizedDescription,
                    asyncRetryAction: {
                        await viewModel.fetchLeitungsteam(isPullToRefresh: false)
                    }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .result(.success(let leitungsteam)):
                // section header with button to select stufe and title of selected stufe
                Section(header: HStack(alignment: .center, spacing: 16) {
                    Text(selectedStufe)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .allowsTightening(true)
                    VStack {
                        Menu {
                            ForEach(leitungsteam.reversed(), id: \.id) { stufe in
                                Button(action: {
                                    withAnimation {
                                        selectedStufe = stufe.teamName
                                    }
                                }) {
                                    HStack {
                                        Text(stufe.teamName)
                                        if selectedStufe == stufe.teamName {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Stufe")
                                Image(systemName: "chevron.up.chevron.down")
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .foregroundStyle(Color.SEESTURM_GREEN)
                            .cornerRadius(16)
                        }
                    }
                    
                }
                .frame(height: 45, alignment: .leading)
                .padding(.vertical, 8)
                ) {
                    if leitungsteam.map({ $0.teamName }).contains(selectedStufe) {
                        ForEach(Array(leitungsteam.filter { $0.teamName == selectedStufe }[0].members.enumerated()), id: \.element.id) { index, member in
                            LeitungsteamCell(member: member)
                                .padding(.bottom)
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.customBackground)
        .scrollDisabled(viewModel.loadingState.scrollingDisabled)
        .refreshable {
            await viewModel.fetchLeitungsteam(isPullToRefresh: true)
        }
        .onAppear {
            withAnimation {
                selectedStufe = passedStufe
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if passedStufe != selectedStufe {
                    withAnimation {
                        selectedStufe = passedStufe
                    }
                }
            }
        }
        .task {
            if viewModel.loadingState.taskShouldRun {
                await viewModel.fetchLeitungsteam(isPullToRefresh: false)
            }
        }
        .navigationTitle("Leitungsteam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LeitungsteamView(
        passedStufe: "Abteilungsleitung"
    )
}
