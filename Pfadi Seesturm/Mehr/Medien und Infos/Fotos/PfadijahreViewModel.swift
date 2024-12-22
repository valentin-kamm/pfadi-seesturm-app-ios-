//
//  PfadijahreViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

@MainActor
class PfadijahreViewModel: ObservableObject {
    
    @Published var pfadijahre: [PfadijahreAlbumResponse] = []
    @Published var loadingState: SeesturmLoadingState = .none
    
    private let photosNetworkManager = PhotosNetworkManager.shared
    
    // function to fetch pfadijahre
    func fetchPfadijahre(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .loading
        }
        do {
            let response = try await photosNetworkManager.fetchPfadijahre()
            withAnimation {
                self.pfadijahre = response.albums.reversed()
                self.loadingState = .success
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
                    self.loadingState = .error(error: pfadiSeesturmError)
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.loadingState = .error(error: pfadiSeesturmError)
            }
        }
        
    }
    
}