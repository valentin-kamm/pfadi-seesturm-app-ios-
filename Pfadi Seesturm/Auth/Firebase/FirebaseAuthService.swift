//
//  FirebaseAuthService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.12.2024.
//

import Foundation

class FirebaseAuthService {
    
    static let shared = FirebaseAuthService()
    
    func getUser(for userId: Int, fromUsers: [FirebaseHitobitoUser]) -> FirebaseHitobitoUser? {
        return fromUsers.first(where: { $0.userId == userId })
    }
    
}
