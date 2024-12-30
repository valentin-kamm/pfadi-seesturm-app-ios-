//
//  FirebaseAuthDataStructures.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

struct FirebaseHitobitoUser: Codable {
    var userId: Int
    var vorname: String
    var nachname: String
    var pfadiname: String
    var email: String
}
extension FirebaseHitobitoUser {
    var displayName: String {
        return pfadiname
    }
}
