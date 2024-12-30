//
//  DokumenteViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI

@MainActor
class DokumenteViewModel: ObservableObject {
    
    @Published var loadingState: SeesturmLoadingState<[TransformedSeesturmWordpressDocumentResponse], PfadiSeesturmAppError> = .none
    
    private let dokumenteLuuchtturmNetworkManager = DokumenteLuuchtturmNetworkManager.shared
    
    // function to fetch the desired posts (downloads) using the network manager
    func fetchDocuments() async {
        
        withAnimation {
            self.loadingState = .loading
        }
        
        do {
            let documents = try await dokumenteLuuchtturmNetworkManager.fetchDocuments(type: "downloads")
            withAnimation {
                self.loadingState = .result(.success(documents.map { $0.toTransformedDocument() }))
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
