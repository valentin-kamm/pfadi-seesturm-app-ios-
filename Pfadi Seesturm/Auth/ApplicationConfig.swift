//
//  ApplicationConfig.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import Foundation

struct ApplicationConfig: Decodable {
    let issuer: String
    let clientID: String
    let redirectUri: String
    let scope: String
}

struct TransformedApplicationConfig {
    let issuer: URL
    let clientID: String
    let redirectUri: URL
    let scopes: [String]
}

extension ApplicationConfig {
    func toValidatedConfig() throws -> TransformedApplicationConfig {
        if URL(string: redirectUri) == nil || URL(string: issuer) == nil {
            throw PfadiSeesturmAppError.authError(message: "Redirect-URI oder Aussteller ungültig.")
        }
        return TransformedApplicationConfig(
            issuer: URL(string: issuer)!,
            clientID: clientID,
            redirectUri: URL(string: redirectUri)!,
            scopes: scope.components(separatedBy: " ")
        )
    }
}
