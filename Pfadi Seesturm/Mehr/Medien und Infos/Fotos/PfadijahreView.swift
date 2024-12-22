//
//  PfadijahreView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct PfadijahreView: View {
    
    @ObservedObject var viewModel: PfadijahreViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                let width = (geometry.size.width - 3 * 16) / 2
                let height = width
                ScrollView {
                    switch viewModel.loadingState {
                    case .none, .loading, .errorWithReload(_):
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(1..<100) { _ in
                                PhotoGalleryLoadingCell(width: width, height: height, withText: true)
                            }
                        }
                        .padding(.horizontal)
                    case .error(let error):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: error.localizedDescription,
                            asyncRetryAction: {
                                await viewModel.fetchPfadijahre(isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    case .success:
                        if viewModel.pfadijahre.count == 0 {
                            VStack {
                                Text("Keine Fotos")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.pfadijahre, id: \.id) { pfadijahr in
                                    NavigationLink(value: pfadijahr) {
                                        PhotoGalleryCell(
                                            width: width,
                                            height: height,
                                            thumbnailUrl: pfadijahr.thumbnail,
                                            title: pfadijahr.title
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
                .scrollDisabled(viewModel.loadingState.scrollingDisabled)
            }
        }
        .navigationTitle("Fotos")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PfadijahreAlbumResponse.self) { pfadijahr in
            GalleriesView(pfadijahr: pfadijahr)
        }
        .task {
            if viewModel.loadingState.taskShouldRun {
                await viewModel.fetchPfadijahre(isPullToRefresh: false)
            }
        }
    }
}

#Preview("Im Mehr Tab") {
    PfadijahreView(viewModel: PfadijahreViewModel())
}
