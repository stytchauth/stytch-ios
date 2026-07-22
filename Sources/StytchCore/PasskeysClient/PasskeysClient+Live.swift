import AuthenticationServices

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
extension PasskeysClient {
    static let live: Self = .init(
        registerCredential: { domain, challenge, username, userId, excludedCredentialIds in
            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: domain)

            let request = platformProvider.createCredentialRegistrationRequest(
                challenge: challenge,
                name: username, // We likely want to enforce this to be an email or phone number (if acct exists, must also be in active session during registration)
                userID: .init(userId.rawValue.utf8) // WebAuthN backend currently relies on session auth, so isn't a pending user id
            )

            #if !os(tvOS)
            // Honoring excludeCredentials prevents re-registering a credential this user already holds — without it,
            // the platform authenticator silently replaces the local passkey (same rpId + user handle) while the
            // server accumulates orphaned webauthn registrations.
            if #available(iOS 17.4, macCatalyst 16.6, macOS 13.5, *), !excludedCredentialIds.isEmpty {
                request.excludedCredentials = excludedCredentialIds.map { credentialId in
                    ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialId)
                }
            }
            #endif

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = await Delegate()
            controller.delegate = delegate
            // controller.presentationContextProvider = parameters.presentationContextProvider // TODO: consider passing this in as optional param

            let credential: ASAuthorizationCredential
            do {
                credential = try await withCheckedThrowingContinuation { continuation in
                    Task { @MainActor in
                        delegate.continuation = continuation
                        controller.performRequests()
                    }
                }
            } catch {
                #if !os(tvOS)
                if #available(iOS 18.0, macOS 15.0, *),
                   let authorizationError = error as? ASAuthorizationError,
                   authorizationError.code == .matchedExcludedCredential {
                    throw StytchSDKError.passkeyAlreadyRegistered
                }
                #endif
                throw error
            }

            guard let credential = credential as? ASAuthorizationPublicKeyCredentialRegistration else {
                throw StytchSDKError.invalidCredentialType
            }

            return credential
        },
        assertCredential: { domain, challenge, requestBehavior in
            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: domain)

            let request = platformProvider.createCredentialAssertionRequest(challenge: challenge)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = await Delegate()
            controller.delegate = delegate

            let credential: ASAuthorizationCredential = try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    delegate.continuation = continuation
                    #if os(iOS) && !targetEnvironment(macCatalyst)
                    switch requestBehavior {
                    case .autoFill:
                        controller.performAutoFillAssistedRequests()
                    case let .default(preferLocalCredentials):
                        controller.performRequests(options: preferLocalCredentials ? .preferImmediatelyAvailableCredentials : [])
                    case let .options(requestOptions):
                        controller.performRequests(options: requestOptions)
                    }
                    #else
                    controller.performRequests()
                    #endif
                }
            }

            guard let credential = credential as? ASAuthorizationPublicKeyCredentialAssertion else {
                throw StytchSDKError.invalidCredentialType
            }

            return credential
        }
    )
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
extension PasskeysClient {
    final class Delegate: NSObject, ASAuthorizationControllerDelegate {
        var continuation: CheckedContinuation<ASAuthorizationCredential, Error>?

        func authorizationController(
            controller _: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization
        ) {
            continuation?.resume(returning: authorization.credential)
        }

        func authorizationController(
            controller _: ASAuthorizationController,
            didCompleteWithError error: Error
        ) {
            continuation?.resume(throwing: error)
        }
    }
}
#endif
