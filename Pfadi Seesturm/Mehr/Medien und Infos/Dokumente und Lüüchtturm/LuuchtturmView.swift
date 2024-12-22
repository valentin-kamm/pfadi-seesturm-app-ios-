//
//  LuuchtturmView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct LuuchtturmView: View {
    
    @StateObject private var viewModel: LuuchtturmViewModel = LuuchtturmViewModel()
    
    var body: some View {
        List {
            switch viewModel.loadingState {
            case .none, .loading, .errorWithReload(_):
                ForEach(1..<10) { index in
                    DokumenteLuuchtturmLoadingCell()
                        .listRowSeparator(.automatic)
                        .listRowInsets(EdgeInsets())
                }
            case .error(let error):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: error.localizedDescription,
                    asyncRetryAction: {
                        await viewModel.fetchDocuments()
                    }
                )
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            case .success:
                ForEach(Array(viewModel.documents.enumerated()), id: \.element.id) { index, document in
                    if let documentUrl = URL(string: document.url) {
                        Link(destination: documentUrl) {
                            DokumenteLuuchtturmCell(document: document)
                        }
                        .foregroundStyle(Color.primary)
                        .listRowSeparator(.automatic)
                        .listRowInsets(EdgeInsets())
                    }
                    else {
                        DokumenteLuuchtturmCell(document: document)
                            .listRowSeparator(.automatic)
                            .listRowInsets(EdgeInsets())
                            .opacity(0.5)
                    }
                }
            }
        }
            .background(Color.customBackground)
            .myListStyle(isListPlain: viewModel.loadingState.isError)
            .scrollDisabled(viewModel.loadingState.scrollingDisabled)
            .task {
                if viewModel.loadingState.taskShouldRun {
                    await viewModel.fetchDocuments()
                }
            }
            .navigationTitle("Lüüchtturm")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LuuchtturmView()
}
