//
//  HitobitoAuthService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//
import SwiftUI
@preconcurrency import AppAuth
import AuthenticationServices

class HitobitoAuthService: NSObject, @unchecked Sendable {
    
    static let shared = HitobitoAuthService()
    
    var userAgentSession: OIDExternalUserAgentSession?
    private var userAgent: OIDExternalUserAgentIOS?
    
    func authenticate(changeStatus: (AuthState) -> Void) async {
        do {
            let appConfig = try getAppConfig()
            changeStatus(.signingIn)
            let serviceConfig = try await fetchIssuerMetadata(appConfig: appConfig)
            let authResponse = try await performAuthorizationRedirect(
                serviceConfig: serviceConfig,
                appConfig: appConfig
            )
            let tokenResponse = try await redeemCodeForTokens(
                authResponse: authResponse,
                appConfig: appConfig
            )
            // TODO: - Weitere Schritte für Auth implementieren nachdem MiData aktiviert
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                changeStatus(.signedOut)
            }
            else {
                changeStatus(.error(error: pfadiSeesturmError))
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.authError(message: "Unbekannter Fehler: \(error.localizedDescription)")
            changeStatus(.error(error: pfadiSeesturmError))
        }
    }
    
    // function that gets the code and returns it for a token
    private func redeemCodeForTokens(
        authResponse: OIDAuthorizationResponse,
        appConfig: TransformedApplicationConfig
    ) async throws -> OIDTokenResponse {
        
        let extraParams = [String: String]()
        guard let request = authResponse.tokenExchangeRequest(withAdditionalParameters: extraParams) else {
            throw PfadiSeesturmAppError.authError(message: "Code kann nicht gegen Token eingetauscht werden.")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(
                request,
                originalAuthorizationResponse: authResponse
            ) { tokenResponse, error in
                    if let error = error {
                        continuation.resume(throwing: PfadiSeesturmAppError.authError(message: "Code kann nicht gegen Token eingetauscht werden: \(error.localizedDescription)"))
                    }
                    else if let response = tokenResponse {
                        continuation.resume(returning: response)
                    }
                    else {
                        continuation.resume(throwing: PfadiSeesturmAppError.authError(message: "Unbekannter Fehler."))
                    }
                }
        }
        
    }

    // function that presents the web view and performs the redirect after successful login
    private func performAuthorizationRedirect(
        serviceConfig: OIDServiceConfiguration,
        appConfig: TransformedApplicationConfig
    ) async throws -> OIDAuthorizationResponse {
        
        let extraParams = ["prompt": "login"]
        let request = OIDAuthorizationRequest(
            configuration: serviceConfig,
            clientId: appConfig.clientID,
            clientSecret: nil,
            scopes: appConfig.scopes,
            redirectURL: appConfig.redirectUri,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams
        )

        let viewController = try getViewController()
        self.userAgent = OIDExternalUserAgentIOS(presenting: viewController)
        guard let iosUserAgent = userAgent else {
            throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.userAgentSession = OIDAuthorizationService.present(
                    request,
                    externalUserAgent: iosUserAgent
                ) { authResponse, error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == OIDGeneralErrorDomain && nsError.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
                            continuation.resume(throwing: PfadiSeesturmAppError.cancellationError(message: "Login durch Benutzer abgebrochen."))
                        }
                        else {
                            continuation.resume(throwing: PfadiSeesturmAppError.authError(message: "Anmeldeprozess wurde unterbrochen: \(error.localizedDescription)"))
                        }
                    }
                    else if let response = authResponse {
                        continuation.resume(returning: response)
                    }
                    else {
                        continuation.resume(throwing: PfadiSeesturmAppError.authError(message: "Unbekannter Fehler."))
                    }
                }
            }
        }
        
    }
    
    // modify OIDC configuration to feature my own token endpoint
    private func modifyIssuerMetadata(oldConfig: OIDServiceConfiguration) -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: oldConfig.authorizationEndpoint,
            tokenEndpoint: Constants.OAUTH_TOKEN_ENDPOINT,
            issuer: oldConfig.issuer,
            registrationEndpoint: oldConfig.registrationEndpoint,
            endSessionEndpoint: oldConfig.endSessionEndpoint
        )
    }
    
    // get configuration from OIDC issuer
    private func fetchIssuerMetadata(appConfig: TransformedApplicationConfig) async throws -> OIDServiceConfiguration {
        return try await modifyIssuerMetadata(oldConfig: OIDAuthorizationService.discoverConfiguration(forIssuer: appConfig.issuer))
    }
    
    // function that fetches app configuration
    private func getAppConfig() throws -> TransformedApplicationConfig {
        return try Constants.OAUTH_CONFIG.toValidatedConfig()
    }
    
    // function that gets the currently presented viewController
    private func getViewController() throws -> UIViewController {
        var rootViewController: UIViewController?
        var capturedError: Error?
        DispatchQueue.main.sync {
            do {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
                }
                guard let vc = scene.keyWindow?.rootViewController else {
                    throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
                }
                rootViewController = vc
            }
            catch {
                capturedError = error
            }
        }
        if let error = capturedError {
            throw error
        }
        guard let result = rootViewController else {
            throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        return result
    }
    
}
