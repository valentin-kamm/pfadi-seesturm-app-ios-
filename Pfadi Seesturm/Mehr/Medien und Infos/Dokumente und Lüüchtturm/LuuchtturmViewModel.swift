//
//  LuuchtturmViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI

@MainActor
class LuuchtturmViewModel: ObservableObject {
    
    @Published var documents: [TransformedSeesturmWordpressDocumentResponse] = []
    @Published var loadingState: SeesturmLoadingState = .none
    
    private let dokumenteLuuchtturmNetworkManager = DokumenteLuuchtturmNetworkManager.shared
    
    // function to fetch the desired posts (downloads) using the network manager
    func fetchDocuments() async {
        
        withAnimation {
            self.loadingState = .loading
        }
        
        do {
            let documents = try await dokumenteLuuchtturmNetworkManager.fetchDocuments(type: "luuchtturm")
            withAnimation {
                self.documents = documents.map { $0.toTransformedDocument() }
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
