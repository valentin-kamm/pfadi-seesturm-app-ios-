//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

@MainActor
class GalleriesViewModel: ObservableObject {
    
    @Published var loadingState: SeesturmLoadingState<[PhotoGalleryResponse], PfadiSeesturmAppError> = .none
    
    private let photosNetworkManager = PhotosNetworkManager.shared
    
    // function to fetch pfadijahre
    func fetchGalleries(id: String, isPullToRefresh: Bool) async {
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .loading
        }
        do {
            let response = try await photosNetworkManager.fetchGalleries(id: id)
            withAnimation {
                self.loadingState = .result(.success(response.galleries))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.loadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.loadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.loadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
}
