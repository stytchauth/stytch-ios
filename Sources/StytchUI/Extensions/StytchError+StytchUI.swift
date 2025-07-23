import StytchCore

extension StytchError {
    func getLocalizedErrorMessage() -> String {
        if let apiError = self.stytchAPIError {
            return switch apiError.errorType {
            case .unauthorizedCredentials:
                LocalizationManager.stytch_error_unauthorized_credentials
            case .userUnauthenticated:
                LocalizationManager.stytch_error_user_unauthenticated
            case .emailNotFound:
                LocalizationManager.stytch_error_email_not_found
            case .otpCodeNotFound:
                LocalizationManager.stytch_error_otp_code_not_found
            case .breachedPassword:
                LocalizationManager.stytch_error_breached_password
            case .noUserPassword:
                LocalizationManager.stytch_error_no_user_password
            case .invalidCode:
                LocalizationManager.stytch_error_invalid_code
            case .tooManyRequests:
                LocalizationManager.stytch_error_too_many_requests
            case .sessionNotFound:
                LocalizationManager.stytch_error_session_not_found
            case .userLockLimitReached:
                LocalizationManager.stytch_error_user_lock_limit_reached
            case .resetPassword:
                LocalizationManager.stytch_error_reset_password
            case .unableToAuthOtpCode:
                LocalizationManager.stytch_error_unable_to_auth_otp_code
            case .noActiveBiometricRegistrations:
                LocalizationManager.stytch_error_no_active_biometric_registrations
            case .unableToAuthMagicLink:
                LocalizationManager.stytch_error_unable_to_auth_magic_link
            case .phoneNumberNotFound:
                LocalizationManager.stytch_error_phone_number_not_found
            case .invalidPhoneNumberCountryCode:
                LocalizationManager.stytch_error_invalid_phone_number_country_code
            case .sessionTooOldToResetPassword:
                LocalizationManager.stytch_error_session_too_old_to_reset_password
            case .invalidEmail:
                LocalizationManager.stytch_error_invalid_email
            case .unauthorizedAction:
                LocalizationManager.stytch_error_unauthorized_action
            case .weakPassword:
                LocalizationManager.stytch_error_weak_password
            case .duplicateEmail:
                LocalizationManager.stytch_error_duplicate_email
            case .invalidPhoneNumber:
                LocalizationManager.stytch_error_invalid_phone_number
            case .oauthAuthCodeError:
                LocalizationManager.stytch_error_oauth_auth_code_error
            case .oauthFlowCallbackError:
                LocalizationManager.stytch_error_oauth_flow_callback_error
            case .oauthTokenNotFound:
                LocalizationManager.stytch_error_oauth_token_not_found
            case .pkceMismatch:
                LocalizationManager.stytch_error_pkce_mismatch
            case .adBlockerDetected:
                LocalizationManager.stytch_error_ad_blocker_detected
            case .staleFactors:
                LocalizationManager.stytch_error_stale_factors
            case .internalServerError:
                LocalizationManager.stytch_error_internal_server_error
            case .invalidMethodId:
                LocalizationManager.stytch_error_invalid_method_id
            case .unableToAuthBiometricRegistration:
                LocalizationManager.stytch_error_unable_to_auth_biometric_registration
            case .unsubscribedPhoneNumber:
                LocalizationManager.stytch_error_unsubscribed_phone_number
            case .emailTemplateNotFound:
                LocalizationManager.stytch_error_email_template_not_found
            case .pkceExpectedCodeVerifier:
                LocalizationManager.stytch_error_pkce_expected_code_verifier
            case .captchaRequired:
                LocalizationManager.stytch_error_captcha_required
            case .inactiveEmail:
                LocalizationManager.stytch_error_inactive_email
            case .memberPasswordNotFound:
                LocalizationManager.stytch_error_member_password_not_found
            case .serverUnavailable:
                LocalizationManager.stytch_error_server_unavailable
            case .tooManyBiometricRegistrationsForUser:
                LocalizationManager.stytch_error_too_many_biometric_registrations_for_user
            case .duplicatePhoneNumber:
                LocalizationManager.stytch_error_duplicate_phone_number
            case .oauthInvalidCallbackRequest:
                LocalizationManager.stytch_error_oauth_invalid_callback_request
            case .intermediateSessionNotFound:
                LocalizationManager.stytch_error_intermediate_session_not_found
            case .noMatchForProvidedMagicLinkUrl:
                LocalizationManager.stytch_error_no_match_for_provided_magic_link_url
            case .totpCodeAlreadyAuthenticated:
                LocalizationManager.stytch_error_totp_code_already_authenticated
            case .invalidSessionDurationMinutes:
                LocalizationManager.stytch_error_invalid_session_duration_minutes
            case .invalidConsumerEndpoint:
                LocalizationManager.stytch_error_invalid_consumer_endpoint
            case .crossOrgPasswordsNotEnabled:
                LocalizationManager.stytch_error_cross_org_passwords_not_enabled
            case .invalidSessionDuration:
                LocalizationManager.stytch_error_invalid_session_duration
            case .invalidLocale:
                LocalizationManager.stytch_error_invalid_locale
            case .magicLinkNotFound:
                LocalizationManager.stytch_error_magic_link_not_found
            default:
                self.message
            }
        }
        return self.message
    }
}
