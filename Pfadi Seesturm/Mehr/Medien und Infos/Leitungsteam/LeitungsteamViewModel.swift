//
//  LeitungsteamViewmodel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

@MainActor
class LeitungsteamViewModel: ObservableObject {
    
    @Published var leitungsteam: LeitungsteamResponse = LeitungsteamResponse()
    @Published var loadingState: SeesturmLoadingState = .none
    
    private let networkManager = LeitungsteamNetworkManager.shared
    
    func fetchLeitungsteam(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.loadingState = isPullToRefresh ? loadingState : .none
        }
        do {
            let response = try await networkManager.fetchMembers()
            withAnimation {
                self.leitungsteam = response
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
