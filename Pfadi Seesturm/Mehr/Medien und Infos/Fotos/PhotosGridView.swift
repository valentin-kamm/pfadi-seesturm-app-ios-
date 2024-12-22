//
//  PhotosGridView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotosGridView: View {
    
    var gallery: PhotoGalleryResponse
    @StateObject var viewModel: PhotosGridViewModel = PhotosGridViewModel()
    
    // variables that are needed to present the photo slider
    @State var showModal: Bool = false
    @State var selectedImageIndex: Int = 0
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                let width = (geometry.size.width - 2 * 2) / 3
                let height = width
                ScrollView {
                    switch viewModel.loadingState {
                    case .none, .loading, .errorWithReload(_):
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(1..<100) { _ in
                                PhotoGalleryLoadingCell(width: width, height: height, withText: false)
                            }
                        }
                    case .error(let error):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: error.localizedDescription,
                            asyncRetryAction: {
                                await viewModel.fetchPhotos(id: gallery.id, isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    case .success:
                        if viewModel.images.count == 0 {
                            VStack {
                                Text("Keine Fotos")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(viewModel.images, id: \.id) { image in
                                    PhotoGalleryCell(
                                        width: width,
                                        height: height,
                                        thumbnailUrl: image.thumbnail
                                    )
                                    // navigate to photo slider
                                    .onTapGesture {
                                        selectedImageIndex = viewModel.images.firstIndex(where: { $0.id == image.id }) ?? 0
                                        showModal = true
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollDisabled(viewModel.loadingState.scrollingDisabled)
            }
        }
        .navigationTitle(gallery.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showModal) {
            PhotoSlider(
                selectedImageIndex: $selectedImageIndex,
                images: viewModel.images
            )
        }
        .task {
            if viewModel.loadingState.taskShouldRun {
                await viewModel.fetchPhotos(id: gallery.id, isPullToRefresh: false)
            }
        }
    }
}

#Preview {
    PhotosGridView(
        gallery: PhotoGalleryResponse(
            title: "Test",
            id: "256",
            thumbnail: ""
        )
    )
}
