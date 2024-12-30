//
//  LeitungsteamViewmodel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

@MainActor
class LeitungsteamViewModel: ObservableObject {
    
    @Published var loadingState: SeesturmLoadingState<LeitungsteamResponse, PfadiSeesturmAppError> = .none
    
    private let networkManager = LeitungsteamNetworkManager.shared
    
    func fetchLeitungsteam(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .none
        }
        do {
            let response = try await networkManager.fetchMembers()
            withAnimation {
                self.loadingState = .result(.success(response))
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
