//
//  GalleriesView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct GalleriesView: View {
    
    var pfadijahr: PfadijahreAlbumResponse
    @StateObject var viewModel: GalleriesViewModel = GalleriesViewModel()
    
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
                        .padding()
                    case .result(.failure(let error)):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: error.localizedDescription,
                            asyncRetryAction: {
                                await viewModel.fetchGalleries(id: pfadijahr.id, isPullToRefresh: false)
                            })
                        .padding(.vertical)
                    case .result(.success(let galleries)):
                        if galleries.count == 0 {
                            VStack {
                                Text("Keine Fotos")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(galleries, id: \.id) { gallery in
                                    NavigationLink(value: gallery) {
                                        PhotoGalleryCell(
                                            width: width,
                                            height: height,
                                            thumbnailUrl: gallery.thumbnail,
                                            title: gallery.title
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
        .navigationTitle(pfadijahr.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.loadingState.taskShouldRun {
                await viewModel.fetchGalleries(id: pfadijahr.id, isPullToRefresh: false)
            }
        }
        .navigationDestination(for: PhotoGalleryResponse.self) { gallery in
            PhotosGridView(gallery: gallery)
        }
    }
}

#Preview {
    GalleriesView(
        pfadijahr: PfadijahreAlbumResponse(title: "Pfadijahr 2023", id: "25", thumbnail: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG")
    )
}
