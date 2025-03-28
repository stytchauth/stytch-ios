import Combine
import Foundation
import StytchCore
import UIKit

enum B2BAuthenticationManager {
    static var dismissUI: AnyPublisher<Void, Never> {
        dismissUIPublisher.eraseToAnyPublisher()
    }

    private static let dismissUIPublisher = PassthroughSubject<Void, Never>()

    /// Values from the primary B2BMFAAuthenticateResponseDataType
    private(set) static var b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType?
    static var primaryRequired: StytchB2BClient.PrimaryRequired? {
        b2bMFAAuthenticateResponse?.primaryRequired
    }

    /// totp related fields
    private(set) static var totpResponse: StytchB2BClient.TOTP.CreateResponseData?
    static var recoveryCodes: [String] {
        totpResponse?.recoveryCodes ?? []
    }

    fileprivate private(set) static var didSaveRecoveryCodes: Bool = false

    /// Values from the secondary B2BAuthenticateResponseDataType
    private(set) static var b2bAuthenticateResponse: B2BAuthenticateResponseDataType?

    static var isAuthenticated: Bool {
        b2bAuthenticateResponse?.memberSession != nil || b2bMFAAuthenticateResponse?.memberSession != nil
    }

    static func handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: B2BMFAAuthenticateResponseDataType) {
        Self.b2bMFAAuthenticateResponse = b2bMFAAuthenticateResponse
        OrganizationManager.updateOrganization(b2bMFAAuthenticateResponse.organization)
        MemberManager.updateMember(b2bMFAAuthenticateResponse.member)
        dismissUIIfNeeded()
    }

    static func handleSecondaryReponse(b2bAuthenticateResponse: B2BAuthenticateResponseDataType) {
        Self.b2bAuthenticateResponse = b2bAuthenticateResponse
        dismissUIIfNeeded()
    }

    static func recoveryCodesSaved() {
        didSaveRecoveryCodes = true
        dismissUIIfNeeded()
    }

    static func handleTOTPResponse(totpResponse: StytchB2BClient.TOTP.CreateResponseData) {
        Self.totpResponse = totpResponse
    }

    static func dismissUIIfNeeded() {
        var memberSession: MemberSession?
        if let secondaryResponse = b2bAuthenticateResponse {
            memberSession = secondaryResponse.memberSession
        } else if let primaryResponse = b2bMFAAuthenticateResponse {
            memberSession = primaryResponse.memberSession
        }

        // If we have a member session we are fully authenticated
        // We then need to check if we have a totpResponse which would only happen if this was a first time flow and the user was creating their totp association
        // So if the totp response is not nil we want to wait to dismiss the ui until the user has saved the recovery codes
        if memberSession != nil {
            if totpResponse == nil || (totpResponse != nil && didSaveRecoveryCodes == true) {
                EventsClient.sendAuthenticationSuccessEvent()
                dismissUIPublisher.send()
            }
        }
    }

    static func reset() {
        b2bMFAAuthenticateResponse = nil
        totpResponse = nil
        b2bAuthenticateResponse = nil
        didSaveRecoveryCodes = false
    }
}
