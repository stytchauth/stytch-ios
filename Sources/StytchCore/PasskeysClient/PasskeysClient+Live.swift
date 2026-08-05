import AuthenticationServices

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
extension PasskeysClient {
    static let live: Self = .init(
        registerCredential: { domain, challenge, username, userId in
            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: domain)

            let request = platformProvider.createCredentialRegistrationRequest(
                challenge: challenge,
                name: username, // We likely want to enforce this to be an email or phone number (if acct exists, must also be in active session during registration)
                userID: .init(userId.rawValue.utf8) // WebAuthN backend currently relies on session auth, so isn't a pending user id
            )

            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = await Delegate()
            controller.delegate = delegate
            // controller.presentationContextProvider = parameters.presentationContextProvider // TODO: consider passing this in as optional param

            let credential: ASAuthorizationCredential = try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    delegate.continuation = continuation
                    controller.performRequests()
                }
            }

            guard let credential = credential as? ASAuthorizationPublicKeyCredentialRegistration else {
                throw StytchSDKError.invalidCredentialType
            }

            return credential
        },
        assertCredential: { domain, challenge, allowedCredentialIds, requestBehavior in
            let platformProvider: ASAuthorizationPlatformPublicKeyCredentialProvider = .init(relyingPartyIdentifier: domain)

            let request = platformProvider.createCredentialAssertionRequest(challenge: challenge)

            // Honoring allowCredentials restricts the sheet to the credentials the server issued the
            // challenge for — without it, a second-factor prompt offers every passkey on the device
            // for this domain, including ones belonging to other accounts.
            if !allowedCredentialIds.isEmpty {
                request.allowedCredentials = allowedCredentialIds.map { credentialId in
                    ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialId)
                }
            }

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
