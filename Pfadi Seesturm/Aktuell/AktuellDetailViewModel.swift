//
//  AktuellDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI

@MainActor
class AktuellDetailViewModel: ObservableObject {
    
    @Published var post: TransformedAktuellPostResponse = TransformedAktuellPostResponse()
    @Published var loadingState: SeesturmLoadingState = .none
    
    @Published var currentPostId: Int = 0
    
    private let aktuellNetworkManager = AktuellNetworkManager.shared
    
    // function to fetch the desired post using the network manager
    func fetchPost(by id: Int, isPullToRefresh: Bool) async {
        
        currentPostId = id
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .loading
        }
        
        do {
            let post = try await aktuellNetworkManager.fetchPost(by: id)
            withAnimation {
                self.post = post.toTransformedPost()
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
