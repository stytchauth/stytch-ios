import Foundation

/*
 NOTE TO CONTRIBUTORS:

 All string keys and variable names should follow this convention: use underscores in variable names and periods in string keys.
 For example: stytch_continue_button → stytch.continue.button

 Whenever you make changes to this file, regenerate the sample localization file used by consumers
 of the Stytch iOS SDK by running the following command from the root of the repository:
 "rm -rf Localization-Sample-File/Localizable.strings && genstrings -o Localization-Sample-File Sources/**/*.swift"
 */

// swiftlint:disable identifier_name type_contents_order file_length
class LocalizationManager {}

// Common Strings Across B2B and B2C
extension LocalizationManager {
    static var stytch_alert_ok: String {
        NSLocalizedString("stytch.alert.ok", value: "OK", comment: "")
    }

    static var stytch_continue_button: String {
        NSLocalizedString("stytch.continue.button", value: "Continue", comment: "Title of the Continue button throughout the Stytch prebuilt UI.")
    }

    static var stytch_email_input_title: String {
        NSLocalizedString("stytch.email.input.title", value: "Email", comment: "")
    }

    static var stytch_error_alert_title: String {
        NSLocalizedString("stytch.error.alert.title", value: "Error", comment: "")
    }

    static var stytch_invalid_email: String {
        NSLocalizedString("stytch.invalid.email", value: "Invalid email address, please try again.", comment: "")
    }

    static var stytch_invalid_phone_number: String {
        NSLocalizedString("stytch.invalid.phone.number", value: "Invalid number, please try again.", comment: "")
    }

    static func stytch_luds_feedback_characters(ludsComplexity: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.luds.feedback.characters", value: "Must contain %@ of the following: uppercase letter, lowercase letter, number, symbol", comment: "LUDS password feedback shown when the user's password does not meet the required character types."),
            ludsComplexity
        )
    }

    static func stytch_luds_feedback_length(ludsMinimumCount: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.luds.feedback.length", value: "Must be at least %@ characters long", comment: "LUDS password feedback shown when the user's password is shorter than the required minimum length."),
            ludsMinimumCount
        )
    }

    static var stytch_luds_feedback_password_reuse: String {
        NSLocalizedString("stytch.luds.feedback.password.reuse", value: "This password may have been used on a different site that experienced a security issue. Please choose another password.", comment: "LUDS password feedback shown when the entered password has likely been exposed in a known data breach.")
    }

    static func stytch_oauth_third_party_title(providerName: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.oauth.third.party.title", value: "Continue with %@", comment: "Button title for continuing with a third-party OAuth provider (e.g., Google, Microsoft)."),
            providerName
        )
    }

    static var stytch_or_separator: String {
        NSLocalizedString("stytch.or.separator", value: "or", comment: "")
    }

    static var stytch_otp_alert_cancel: String {
        NSLocalizedString("stytch.otp.alert.cancel", value: "Cancel", comment: "Cancel button label in the OTP resend confirmation alert.")
    }

    static var stytch_otp_alert_confirm: String {
        NSLocalizedString("stytch.otp.alert.confirm", value: "Send code", comment: "Confirm button label in the OTP resend confirmation alert.")
    }

    static func stytch_otp_alert_message_new_code_will_be_sent(recipient: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.otp.alert.message.new.code.will.be.sent", value: "A new code will be sent to %@.", comment: "Message displayed in the OTP resend confirmation alert indicating a new code will be sent to the specified destination."),
            recipient
        )
    }

    static var stytch_otp_alert_title_resend_code: String {
        NSLocalizedString("stytch.otp.alert.title.resend.code", value: "Resend code", comment: "Title of the OTP resend confirmation alert.")
    }

    static var stytch_otp_code_expired: String {
        NSLocalizedString("stytch.otp.code.expired", value: "Your code has expired. Didn't get it? Resend it.", comment: "Message displayed on OTP entry screens when the code has expired, prompting the user to resend.")
    }

    static func stytch_otp_code_expires_in(timeString: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.otp.code.expires.in", value: "Your code expires in %@. Didn't get it? Resend it.", comment: "Message displayed on OTP entry screens indicating how much time is left before the code expires, with a prompt to resend."),
            timeString
        )
    }

    static var stytch_password_input_label: String {
        NSLocalizedString("stytch.password.input.label", value: "Password", comment: "")
    }

    static var stytch_zxcvbn_feedback_success: String {
        NSLocalizedString("stytch.zxcvbn.feedback.success", value: "Great job! This is a strong password.", comment: "Positive feedback message shown when the entered password is evaluated as strong by the zxcvbn password criteria.")
    }
}

// Strings For B2C
extension LocalizationManager {
    static var stytch_b2c_biometrics_enable_button_face_id: String {
        NSLocalizedString("stytch.b2c.biometrics.enable.button.face.id", value: "Enable Face ID", comment: "")
    }

    static var stytch_b2c_biometrics_enable_button_touch_id: String {
        NSLocalizedString("stytch.b2c.biometrics.enable.button.touch.id", value: "Enable Touch ID", comment: "")
    }

    static var stytch_b2c_biometrics_subtitle_face_id: String {
        NSLocalizedString("stytch.b2c.biometrics.subtitle.face.id", value: "Use Face ID to log into your account. You will be prompted to allow this app to use Face ID.", comment: "")
    }

    static var stytch_b2c_biometrics_subtitle_touch_id: String {
        NSLocalizedString("stytch.b2c.biometrics.subtitle.touch.id", value: "Use Touch ID to log into your account. You will be prompted to allow this app to use Touch ID.", comment: "")
    }

    static var stytch_b2c_biometrics_title_face_id: String {
        NSLocalizedString("stytch.b2c.biometrics.title.face.id", value: "Enable Face ID login?", comment: "")
    }

    static var stytch_b2c_biometrics_title_touch_id: String {
        NSLocalizedString("stytch.b2c.biometrics.title.touch.id", value: "Enable Touch ID login?", comment: "")
    }

    static var stytch_b2c_biometrics_skip_for_now: String {
        NSLocalizedString("stytch.b2c.biometrics.skip.for.now", value: "Skip for now", comment: "")
    }

    static var stytch_b2c_create_password_instead: String {
        NSLocalizedString("stytch.b2c.create.password.instead", value: "Create a password instead", comment: "")
    }

    static var stytch_b2c_email_confirmation_alert_cancel: String {
        NSLocalizedString("stytch.b2c.email.confirmation.cancel", value: "Cancel", comment: "")
    }

    static var stytch_b2c_email_confirmation_alert_confirm: String {
        NSLocalizedString("stytch.b2c.email.confirmation.confirm", value: "Send link", comment: "")
    }

    static func stytch_b2c_email_confirmation_alert_message(email: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.b2c.email.confirmation.alert.message", value: "A new link will be sent to %@.", comment: ""),
            email
        )
    }

    static var stytch_b2c_email_confirmation_alert_title: String {
        NSLocalizedString("stytch.b2c.email.confirmation.resend.link", value: "Resend link", comment: "")
    }

    static var stytch_b2c_email_confirmation_check_email: String {
        NSLocalizedString("stytch.b2c.email.confirmation.check.email", value: "Check your email", comment: "")
    }

    static var stytch_b2c_email_confirmation_check_email_for_password: String {
        NSLocalizedString("stytch.b2c.email.confirmation.check.email.for.password", value: "Check your email to set a new password", comment: "")
    }

    static var stytch_b2c_email_confirmation_didnt_get_it_resend_email: String {
        NSLocalizedString("stytch.b2c.email.confirmation.didnt.get.it", value: "Didn't get it? Resend email", comment: "")
    }

    static var stytch_b2c_email_confirmation_link_to_reset_password_sent: String {
        NSLocalizedString("stytch.b2c.email.confirmation.link.to.reset.password.sent", value: "A link to reset your password was sent to you at ", comment: "")
    }

    static var stytch_b2c_email_confirmation_login_link_sent: String {
        NSLocalizedString("stytch.b2c.email.confirmation.login.link.sent", value: "A login link was sent to you at ", comment: "")
    }

    static var stytch_b2c_email_confirmation_login_without_password: String {
        NSLocalizedString("stytch.b2c.email.confirmation.login.without.password", value: "Login without a password", comment: "")
    }

    static var stytch_b2c_email_confirmation_make_sure_acount_secure: String {
        NSLocalizedString("stytch.b2c.email.confirmation.make.sure.acount.secure", value: "We want to make sure your account is secure and that it’s really you logging in. A login link was sent to you at ", comment: "")
    }

    static var stytch_b2c_email_confirmation_password_breach: String {
        NSLocalizedString("stytch.b2c.email.confirmation.password.breach", value: "A different site where you use the same password had a security issue recently. For your safety, an email was sent to you at ", comment: "")
    }

    static var stytch_b2c_email_confirmation_to_create_password: String {
        NSLocalizedString("stytch.b2c.email.confirmation.to.create.password", value: " to create a password for your account.", comment: "")
    }

    static var stytch_b2c_email_confirmation_to_reset_password: String {
        NSLocalizedString("stytch.b2c.email.confirmation.to.reset.password", value: " to reset your password.", comment: "")
    }

    static var stytch_b2c_email_placeholder: String {
        NSLocalizedString("stytch.b2c.email.placeholder", value: "example@company.com", comment: "")
    }

    static var stytch_b2c_home_biometrics_continue_with_face_id: String {
        NSLocalizedString("stytch.b2c.home.biometrics.continue.with.face.id", value: "Continue with Face ID", comment: "")
    }

    static var stytch_b2c_home_biometrics_continue_with_touch_id: String {
        NSLocalizedString("stytch.b2c.home.biometrics.continue.with.touch.id", value: "Continue with Touch ID", comment: "")
    }

    static var stytch_b2c_home_email: String {
        NSLocalizedString("stytch.b2c.home.email", value: "Email", comment: "")
    }

    static var stytch_b2c_home_text: String {
        NSLocalizedString("stytch.b2c.home.text", value: "Text", comment: "")
    }

    static var stytch_b2c_home_title: String {
        NSLocalizedString("stytch.b2c.home.title", value: "Sign up or log in", comment: "Title of the home screen")
    }

    static var stytch_b2c_home_whatsApp: String {
        NSLocalizedString("stytch.b2c.home.whatsApp", value: "WhatsApp", comment: "")
    }

    static var stytch_b2c_otp_error: String {
        NSLocalizedString("stytch.b2c.otp.error", value: "Invalid passcode, please try again.", comment: "")
    }

    static var stytch_b2c_otp_message: String {
        NSLocalizedString("stytch.b2c.otp.message", value: "A 6-digit passcode was sent to you at ", comment: "")
    }

    static var stytch_b2c_otp_title: String {
        NSLocalizedString("stytch.b2c.otp.title", value: "Enter passcode", comment: "")
    }

    static var stytch_b2c_password_choose_how_create: String {
        NSLocalizedString("stytch.b2c.password.choose.how.create", value: "Choose how you would like to create your account.", comment: "")
    }

    static var stytch_b2c_password_continue_title: String {
        NSLocalizedString("stytch.b2c.password.continue.title", value: "Continue", comment: "")
    }

    static var stytch_b2c_password_continue_title_email: String {
        NSLocalizedString("stytch.b2c.password.continue.title.email", value: "Continue with email", comment: "")
    }

    static var stytch_b2c_password_continue_try_again_title: String {
        NSLocalizedString("stytch.b2c.password.continue.try.again.title", value: "Try Again", comment: "")
    }

    static var stytch_b2c_password_create_account: String {
        NSLocalizedString("stytch.b2c.password.create.account", value: "Create account", comment: "")
    }

    static var stytch_b2c_password_email_login_link: String {
        NSLocalizedString("stytch.b2c.password.email.login.link", value: "Email me a login link", comment: "")
    }

    static var stytch_b2c_password_finish_creating_label: String {
        NSLocalizedString("stytch.b2c.password.finish.creating.label", value: "Finish creating your account by setting a password.", comment: "")
    }

    static var stytch_b2c_password_forgot: String {
        NSLocalizedString("stytch.b2c.password.forgot", value: "Forgot password?", comment: "")
    }

    static var stytch_b2c_password_log_in: String {
        NSLocalizedString("stytch.b2c.password.log.in", value: "Log in", comment: "")
    }

    static var stytch_b2c_password_set_new_password: String {
        NSLocalizedString("stytch.b2c.password.set.new.password", value: "Set a new password", comment: "")
    }
}

// Strings For B2B
extension LocalizationManager {
    static var stytch_b2b_create_organization_button: String {
        NSLocalizedString("stytch.b2b.create.organization.button", value: "Create an organization", comment: "")
    }

    static func stytch_b2b_create_organization_subtitle(value: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.b2b.create.organization.subtitle", value: "%@ does not have an account. Think this is a mistake? Try a different email address, or contact your admin.", comment: ""), value
        )
    }

    static var stytch_b2b_create_organization_title: String {
        NSLocalizedString("stytch.b2b.create.organization.title", value: "Create an organization to get started", comment: "")
    }

    static var stytch_b2b_discovered_organizations_title: String {
        NSLocalizedString("stytch.b2b.discovered.organizations.title", value: "Select an organization to continue", comment: "")
    }

    static var stytch_b2b_discovery_accept_invite: String {
        NSLocalizedString("stytch.b2b.discovery.accept.invite", value: "Accept Invite", comment: "")
    }

    static var stytch_b2b_discovery_join: String {
        NSLocalizedString("stytch.b2b.discovery.join", value: "Join", comment: "")
    }

    static var stytch_b2b_email_confirmation_check_email: String {
        NSLocalizedString("stytch.b2b.email.confirmation.check.email", value: "Check your email", comment: "")
    }

    static var stytch_b2b_email_confirmation_didnt_get_it: String {
        NSLocalizedString("stytch.b2b.email.confirmation.didnt.get.it", value: "Didn’t get it?", comment: "")
    }

    static var stytch_b2b_email_confirmation_email_sent: String {
        NSLocalizedString("stytch.b2b.email.confirmation.email.sent", value: "An email was sent to", comment: "")
    }

    static var stytch_b2b_email_confirmation_email_sent_alert_title: String {
        NSLocalizedString("stytch.b2b.email.confirmation.email.sent.alert.title", value: "Email Sent!", comment: "")
    }

    static var stytch_b2b_email_confirmation_login_link_sent: String {
        NSLocalizedString("stytch.b2b.email.confirmation.login.link.sent", value: "A login link was sent to you at", comment: "")
    }

    static var stytch_b2b_email_confirmation_resend_email: String {
        NSLocalizedString("stytch.b2b.email.confirmation.resend.email", value: "Resend email", comment: "")
    }

    static var stytch_b2b_email_confirmation_try_again: String {
        NSLocalizedString("stytch.b2b.email.confirmation.try.again", value: "Try Again", comment: "")
    }

    static var stytch_b2b_email_confirmation_verify_email: String {
        NSLocalizedString("stytch.b2b.email.confirmation.verify.email", value: "Please verify your email", comment: "")
    }

    static var stytch_b2b_email_method_code: String {
        NSLocalizedString("stytch.b2b.email.method.code", value: "Email me a log in code", comment: "")
    }

    static var stytch_b2b_email_method_link: String {
        NSLocalizedString("stytch.b2b.email.method.link", value: "Email me a log in link", comment: "")
    }

    static var stytch_b2b_email_method_title: String {
        NSLocalizedString("stytch.b2b.email.method.title", value: "Select how you'd like to continue.", comment: "")
    }

    static func stytch_b2b_email_not_eligible_for_jit_provioning_error(memberEmail: String, orgName: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString(
                "stytch.b2b.email.not.eligible.for.jit.provioning.error",
                value: "%@ does not have access to %@. If you think this is a mistake, contact your admin.",
                comment: "Error message shown when a user is not eligible for just-in-time provisioning due to the organization's authentication policy."
            ),
            memberEmail,
            orgName
        )
    }

    static var stytch_b2b_email_otp_entry_title: String {
        NSLocalizedString("stytch.b2b.email.otp.entry.title", value: "Enter verification code", comment: "")
    }

    static var stytch_b2b_email_otp_passcode_sent: String {
        NSLocalizedString("stytch.b2b.email.otp.passcode.sent", value: "A 6-digit passcode was sent to you at", comment: "")
    }

    static var stytch_b2b_email_use_password_instead: String {
        NSLocalizedString("stytch.b2b.email.use.password.instead", value: "Use password instead", comment: "")
    }

    static var stytch_b2b_error_email_auth_failed: String {
        NSLocalizedString("stytch.b2b.error.email.auth.failed", value: "Something went wrong. Your login link may have expired, been revoked, or been used more than once. Request a new login link to try again, or contact your admin for help.", comment: "")
    }

    static var stytch_b2b_error_generic: String {
        NSLocalizedString("stytch.b2b.error.generic", value: "Something went wrong. Try again later or contact your admin for help.", comment: "")
    }

    static var stytch_b2b_error_invalid_product_configuration: String {
        NSLocalizedString("stytch.b2b.error.invalid.product.configuration", value: "Invalid product configuration detected", comment: "")
    }

    static var stytch_b2b_error_no_org_found: String {
        NSLocalizedString("stytch.b2b.error.no.org.found", value: "The organization you are looking for could not be found. If you think this is a mistake, contact your admin.", comment: "")
    }

    static func stytch_b2b_error_no_primary_auth_methods(orgName: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.b2b.error.no.primary.auth.methods", value: "Unable to join due to %@'s authentication policy. Please contact your admin for more information.", comment: ""),
            orgName
        )
    }

    static var stytch_b2b_error_title: String {
        NSLocalizedString("stytch.b2b.error.title", value: "Looks like there was an error!", comment: "")
    }

    static var stytch_b2b_home_confirm_email: String {
        NSLocalizedString("stytch.b2b.home.confirm.email", value: "Confirm your email address with one of the following", comment: "")
    }

    static func stytch_b2b_home_continue_to_organization(organization: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.b2b.home.continue.to.organization", value: "Continue to %@", comment: ""),
            organization
        )
    }

    static var stytch_b2b_home_sign_up_or_log_in: String {
        NSLocalizedString(
            "stytch.b2b.home.sign.up.or.log.in",
            value: "Sign up or log in",
            comment: "Title displayed on the home screen during the B2B discovery flow."
        )
    }

    static var stytch_b2b_home_verify_email: String {
        NSLocalizedString(
            "stytch.b2b.home.verify.email",
            value: "Verify Your Email",
            comment: "Title displayed on the home screen when additional primary authentication (e.g., email verification) is required."
        )
    }

    static var stytch_b2b_mfa_enrollment_subtitle: String {
        NSLocalizedString(
            "stytch.b2b.mfa.enrollment.subtitle",
            value: "Add an additional form of verification to make your account more secure.",
            comment: "Instructional subtitle displayed on the Multi-Factor Authentication enrollment screen encouraging users to set up an additional verification method."
        )
    }

    static var stytch_b2b_mfa_enrollment_title: String {
        NSLocalizedString(
            "stytch.b2b.mfa.enrollment.title",
            value: "Set up Multi-Factor Authentication",
            comment: "Title displayed on the Multi-Factor Authentication screen prompting users to set up Multi-Factor Authentication for their account."
        )
    }

    static var stytch_b2b_mfa_selection_text: String {
        NSLocalizedString("stytch.b2b.mfa.selection.text", value: "Text me a code", comment: "Label for selecting SMS as the method for receiving a Multi-Factor Authentication verification code.")
    }

    static var stytch_b2b_mfa_selection_totp: String {
        NSLocalizedString(
            "stytch.b2b.mfa.selection.totp",
            value: "Use an authenticator app",
            comment: "Label for selecting an authenticator app as the method for receiving a Multi-Factor Authentication verification code."
        )
    }

    static var stytch_b2b_no_discovered_organizations_subtitle: String {
        NSLocalizedString("stytch.b2b.no.discovered.organizations.subtitle", value: "Make sure your email address is correct. Otherwise, you might need to be invited by your admin.", comment: "")
    }

    static func stytch_b2b_no_discovered_organizations_title(email: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("stytch.b2b.no.discovered.organizations.title", value: "%@ does not belong to any organizations.", comment: ""),
            email
        )
    }

    static var stytch_b2b_no_discovered_organizations_try_differnt_email_address_button: String {
        NSLocalizedString("stytch.b2b.no.discovered.organizations.try.differnt.email.address.button", value: "Try a different email address", comment: "")
    }

    static var stytch_b2b_organization_slug_placeholder: String {
        NSLocalizedString("stytch.b2b.organization.slug.placeholder", value: "Enter Organization Slug", comment: "")
    }

    static var stytch_b2b_otp_message: String {
        NSLocalizedString("stytch.b2b.otp.message", value: "A 6-digit passcode was sent to you at", comment: "")
    }

    static var stytch_b2b_password_authenticate_title: String {
        NSLocalizedString("stytch.b2b.password.authenticate.title", value: "Log in with email and password", comment: "")
    }

    static var stytch_b2b_password_forgot_subtitle: String {
        NSLocalizedString("stytch.b2b.password.forgot.subtitle", value: "We'll email you a login link to sign in to your account directly or reset your password if you have one.", comment: "")
    }

    static var stytch_b2b_password_forgot_title: String {
        NSLocalizedString("stytch.b2b.password.forgot.title", value: "Check your email for help signing in!", comment: "")
    }

    static var stytch_b2b_password_reset_title: String {
        NSLocalizedString("stytch.b2b.password.reset.title", value: "Set a new password", comment: "")
    }

    static var stytch_b2b_password_signup_or_reset: String {
        NSLocalizedString("stytch.b2b.password.signup.or.reset", value: "Sign up or reset password", comment: "")
    }

    static var stytch_b2b_recovery_code_copy: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.copy",
            value: "Copy",
            comment: "Button label for copying all recovery codes to the clipboard during the TOTP registration flow."
        )
    }

    static var stytch_b2b_recovery_code_copied: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.copied",
            value: "Recovery Codes Copied!",
            comment: "Confirmation message shown after all recovery codes have been copied to the clipboard during the TOTP registration flow."
        )
    }

    static var stytch_b2b_recovery_code_done: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.done",
            value: "Done",
            comment: "Button label to complete the recovery code saving step during the TOTP registration flow."
        )
    }

    static var stytch_b2b_recovery_code_entry_subtitle: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.entry.subtitle",
            value: "Enter one of the backup codes you saved when setting up your authenticator app.",
            comment: "Instructional subtitle shown when the user is prompted to enter a recovery code after losing access to their authenticator app."
        )
    }

    static var stytch_b2b_recovery_code_entry_title: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.entry.title",
            value: "Enter backup code",
            comment: "Title displayed when prompting the user to enter a recovery code after losing access to their authenticator app."
        )
    }

    static var stytch_b2b_recovery_code_placeholder: String {
        NSLocalizedString("stytch.b2b.recovery.code.placeholder", value: "Enter backup code", comment: "")
    }

    static var stytch_b2b_recovery_code_save_button: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.save.button",
            value: "Save",
            comment: "Button label for saving recovery codes during the authenticator app setup flow."
        )
    }

    static var stytch_b2b_recovery_code_save_subtitle: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.save.subtitle",
            value: "This is the only time you will be able to access and save your backup codes.",
            comment: "Instructional subtitle indicating that this is the only opportunity to save recovery codes during setup."
        )
    }

    static var stytch_b2b_recovery_code_save_title: String {
        NSLocalizedString(
            "stytch.b2b.recovery.code.save.title",
            value: "Save your backup codes!",
            comment: "Title shown when prompting the user to save their recovery codes during the authenticator app setup flow."
        )
    }

    static var stytch_b2b_sms_otp_enrollment_subtitle: String {
        NSLocalizedString("stytch.b2b.sms.otp.enrollment.subtitle", value: "Your organization requires an additional form of verification to make your account more secure.", comment: "")
    }

    static var stytch_b2b_sms_otp_enrollment_title: String {
        NSLocalizedString("stytch.b2b.sms.otp.enrollment.title", value: "Enter your phone number to set up Multi-Factor Authentication", comment: "")
    }

    static var stytch_b2b_sms_otp_entry_title: String {
        NSLocalizedString("stytch.b2b.sms.otp.entry.title", value: "Enter passcode", comment: "")
    }

    static var stytch_b2b_sso_discovery_button_title: String {
        NSLocalizedString(
            "stytch.b2b.sso.discovery.button.title",
            value: "Continue with SSO",
            comment: "Button used to kick off the discovery SSO flow."
        )
    }

    static func stytch_b2b_sso_button_title(providerName: String) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString(
                "stytch.b2b.sso.button.title",
                value: "Continue with %@",
                comment: "Button used to authenticate with a specific SSO provider."
            ),
            providerName
        )
    }

    static var stytch_b2b_sso_discovery_enter_email: String {
        NSLocalizedString("stytch.b2b.sso.discovery.enter.email", value: "Enter your email to continue", comment: "")
    }

    static var stytch_b2b_sso_discovery_fallback_enter_org_slug: String {
        NSLocalizedString("stytch.b2b.sso.discovery.fallback.enter.org.slug", value: "Please input the Organization's unique slug to continue. If you don't know the unique slug, log in through another method to view all of your available Organizations.", comment: "")
    }

    static var stytch_b2b_sso_discovery_fallback_no_connections: String {
        NSLocalizedString("stytch.b2b.sso.discovery.fallback.no.connections", value: "Sorry, we couldn't find any connections", comment: "")
    }

    static var stytch_b2b_sso_discovery_fallback_try_another_login: String {
        NSLocalizedString("stytch.b2b.sso.discovery.fallback.try.another.login", value: "Try another login method", comment: "")
    }

    static var stytch_b2b_sso_select_connection: String {
        NSLocalizedString(
            "stytch.b2b.sso.select.connection",
            value: "Select a connection to continue",
            comment: "Title displayed when prompting the user to select from multiple SSO connections during the discovery SSO flow."
        )
    }

    static var stytch_b2b_totp_cant_access_authenticator_app: String {
        NSLocalizedString(
            "stytch.b2b.totp.cant.access.authenticator.app",
            value: "Can't access your authenticator app?",
            comment: "Button title shown during TOTP code entry when the user cannot access their authenticator app."
        )
    }

    static var stytch_b2b_totp_enrollment_subtitle: String {
        NSLocalizedString(
            "stytch.b2b.totp.enrollment.subtitle",
            value: "Enter the key below into your authenticator app. If you don’t have an authenticator app, you’ll need to install one first.",
            comment: "Subtitle displayed during TOTP enrollment instructing the user to enter the secret key into their authenticator app."
        )
    }

    static var stytch_b2b_totp_enrollment_title: String {
        NSLocalizedString(
            "stytch.b2b.totp.enrollment.title",
            value: "Copy the code below to link your authenticator app",
            comment: "Title displayed during TOTP enrollment instructing the user to copy the secret key to link their authenticator app."
        )
    }

    static var stytch_b2b_totp_entry_footer: String {
        NSLocalizedString(
            "stytch.b2b.totp.entry.footer",
            value: "If the verification code doesn’t work, go back to your authenticator app to get a new code.",
            comment: "Footer message displayed during TOTP code entry advising the user to retrieve a new code from their authenticator app if the current one doesn't work."
        )
    }

    static var stytch_b2b_totp_entry_subtitle: String {
        NSLocalizedString(
            "stytch.b2b.totp.entry.subtitle",
            value: "Enter the 6-digit code from your authenticator app.",
            comment: "Subtitle displayed during TOTP code entry, instructing the user to enter the 6-digit code from their authenticator app."
        )
    }

    static var stytch_b2b_totp_entry_title: String {
        NSLocalizedString(
            "stytch.b2b.totp.entry.title",
            value: "Enter verification code",
            comment: "Title displayed during TOTP code entry, prompting the user to enter the 6-digit code from their authenticator app."
        )
    }

    static var stytch_b2b_totp_secret_copied: String {
        NSLocalizedString(
            "stytch.b2b.totp.secret.copied",
            value: "Secret Copied!",
            comment: "Confirmation message shown after the user copies the secret key to set up their authenticator app during TOTP enrollment."
        )
    }

    static var stytch_b2b_totp_use_backup_code: String {
        NSLocalizedString(
            "stytch.b2b.totp.use.backup.code",
            value: "Use a backup code.",
            comment: "Button title shown during TOTP code entry that allows the user to switch to using a backup code instead."
        )
    }
}

// ZXCVBN Warnings And Suggestions
extension LocalizationManager {
    static var stytch_zxcvbn_suggestion_1: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.1", value: "Use a few words, avoid common phrases.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_2: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.2", value: "No need for symbols, digits, or uppercase letters.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_3: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.3", value: "Add another word or two. Uncommon words are better.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_4: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.4", value: "Use a longer keyboard pattern with more turns.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_5: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.5", value: "Avoid repeated words and characters.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_6: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.6", value: "Avoid sequences.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_7: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.7", value: "Avoid recent years.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_8: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.8", value: "Avoid years that are associated with you.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_9: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.9", value: "Avoid dates and years that are associated with you.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_10: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.10", value: "Capitalization doesn\'t help very much.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_11: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.11", value: "All-uppercase is almost as easy to guess as all-lowercase.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_12: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.12", value: "Reversed words aren\'t much harder to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_13: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.13", value: "Predictable substitutions like \'@\' instead of \'a\' don\'t help very much.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_14: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.14", value: "Short keyboard patterns are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_15: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.15", value: "Straight rows of keys are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_16: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.16", value: "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\".", comment: "")
    }

    static var stytch_zxcvbn_suggestion_17: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.17", value: "Repeats like \"aaa\" are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_18: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.18", value: "Sequences like \"abc\" or \"6543\" are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_19: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.19", value: "Recent years are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_20: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.20", value: "Dates are often easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_21: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.21", value: "This is a top-10 common password.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_22: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.22", value: "This is a top-100 common password.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_23: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.23", value: "This is a very common password.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_24: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.24", value: "This is similar to a commonly used password.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_25: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.25", value: "A word by itself is easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_26: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.26", value: "Names and surnames by themselves are easy to guess.", comment: "")
    }

    static var stytch_zxcvbn_suggestion_27: String {
        NSLocalizedString("stytch.zxcvbn.suggestion.27", value: "Common names and surnames are easy to guess.", comment: "")
    }
}

// Most common API errors
extension LocalizationManager {
    static var stytch_error_unauthorized_credentials: String {
        NSLocalizedString("stytch.error.unauthorizedcredentials", value: "Unauthorized credentials.", comment: "")
    }

    static var stytch_error_user_unauthenticated: String {
        NSLocalizedString("stytch.error.userunauthenticated", value: "User must have an active Stytch session to call this method. Have you logged in yet?", comment: "")
    }

    static var stytch_error_email_not_found: String {
        NSLocalizedString("stytch.error.emailnotfound", value: "Email could not be found.", comment: "")
    }

    static var stytch_error_otp_code_not_found: String {
        NSLocalizedString("stytch.error.otpcode_notfound", value: "The passcode was incorrect and could not be authenticated, encourage the user to try inputting the passcode again or send another passcode.", comment: "")
    }

    static var stytch_error_breached_password: String {
        NSLocalizedString("stytch.error.breachedpassword", value: "password appears in a list of breached passwords.", comment: "")
    }

    static var stytch_error_no_user_password: String {
        NSLocalizedString("stytch.error.nouserpassword", value: "user doesn't have an associated password.", comment: "")
    }

    static var stytch_error_invalid_code: String {
        NSLocalizedString("stytch.error.invalidcode", value: "Code format is invalid.", comment: "")
    }

    static var stytch_error_too_many_requests: String {
        NSLocalizedString("stytch.error.toomanyrequests", value: "Too many requests have been made.", comment: "")
    }

    static var stytch_error_session_not_found: String {
        NSLocalizedString("stytch.error.sessionnotfound", value: "Session could not be found.", comment: "")
    }

    static var stytch_error_user_lock_limit_reached: String {
        NSLocalizedString("stytch.error.userlocklimitreached", value: "The user has been locked out due to too many failed authentication attempts. Please try again later.", comment: "")
    }

    static var stytch_error_reset_password: String {
        NSLocalizedString("stytch.error.resetpassword", value: "user must reset their password", comment: "")
    }

    static var stytch_error_unable_to_auth_otp_code: String {
        NSLocalizedString("stytch.error.unabletoauthotpcode", value: "The passcode could not be authenticated because it was either already used or expired. Send another passcode to this user.", comment: "")
    }

    static var stytch_error_no_active_biometric_registrations: String {
        NSLocalizedString("stytch.error.noactivebiometricregistrations", value: "No active mobile biometric registrations were found.", comment: "")
    }

    static var stytch_error_unable_to_auth_magic_link: String {
        NSLocalizedString("stytch.error.unabletoauthmagiclink", value: "The magic link could not be authenticated because it was either already used or expired. Send another magic link to this user.", comment: "")
    }

    static var stytch_error_client_closed_request: String {
        NSLocalizedString("stytch.error.clientclosedrequest", value: "Client closed request.", comment: "")
    }

    static var stytch_error_phone_number_not_found: String {
        NSLocalizedString("stytch.error.phonenumbernotfound", value: "Phone Number could not be found.", comment: "")
    }

    static var stytch_error_invalid_phone_number_country_code: String {
        NSLocalizedString("stytch.error.invalidphonenumbercountrycode", value: "The phone number's country code is invalid, unsupported, or disabled.", comment: "")
    }

    static var stytch_error_session_too_old_to_reset_password: String {
        NSLocalizedString("stytch.error.sessiontoooldtoresetpassword", value: "The provided session cannot be used to reset a password. It does not have an authentication_factor that was authenticated within the last 5 minutes. Please prompt the user to authenticate again before retrying the endpoint.", comment: "")
    }

    static var stytch_error_invalid_email: String {
        NSLocalizedString("stytch.error.invalidemail", value: "Email format is invalid.", comment: "")
    }

    static var stytch_error_unauthorized_action: String {
        NSLocalizedString("stytch.error.unauthorizedaction", value: "Unauthorized action.", comment: "")
    }

    static var stytch_error_weak_password: String {
        NSLocalizedString("stytch.error.weakpassword", value: "password doesn't meet our strength requirements.", comment: "")
    }

    static var stytch_error_duplicate_email: String {
        NSLocalizedString("stytch.error.duplicateemail", value: "A user with the specified email already exists for this project.", comment: "")
    }

    static var stytch_error_invalid_phone_number: String {
        NSLocalizedString("stytch.error.invalidphonenumber", value: "Phone number format is invalid. Ensure the phone number is in the E.164 format.", comment: "")
    }

    static var stytch_error_oauth_auth_code_error: String {
        NSLocalizedString("stytch.error.oauthauthcodeerror", value: "An error was encountered when exchanging the OAuth auth code. Please try again.", comment: "")
    }

    static var stytch_error_oauth_flow_callback_error: String {
        NSLocalizedString("stytch.error.oauthflowcallbackerror", value: "An error was encountered in the callback of the OAuth flow. Please try again.", comment: "")
    }

    static var stytch_error_oauth_token_not_found: String {
        NSLocalizedString("stytch.error.oauthtokennotfound", value: "Member OAuth Token not found", comment: "")
    }

    static var stytch_error_pkce_mismatch: String {
        NSLocalizedString("stytch.error.pkcemismatch", value: "The submitted code_verifier does not match the code_challenge sent at the start of the flow.", comment: "")
    }

    static var stytch_error_ad_blocker_detected: String {
        NSLocalizedString("stytch.error.adblockerdetected", value: "The request was blocked by an Ad Blocker. Please disable your ad blocker and try the request again.", comment: "")
    }

    static var stytch_error_stale_factors: String {
        NSLocalizedString("stytch.error.stalefactors", value: "In order to call this endpoint, the user should have authenticated within the last hour. Please reauthenticate and try again.", comment: "")
    }

    static var stytch_error_internal_server_error: String {
        NSLocalizedString("stytch.error.internalservererror", value: "Oops, something seems to have gone wrong. If this issue persists, please reach out to support.", comment: "")
    }

    static var stytch_error_invalid_method_id: String {
        NSLocalizedString("stytch.error.invalidmethodid", value: "method_id format is invalid.", comment: "")
    }

    static var stytch_error_unable_to_auth_biometric_registration: String {
        NSLocalizedString("stytch.error.unabletoauthbiometricregistration", value: "Biometric registration could not be authenticated.", comment: "")
    }

    static var stytch_error_unsubscribed_phone_number: String {
        NSLocalizedString("stytch.error.unsubscribedphonenumber", value: "User has unsubscribed. User must resubscribe by texting 'START' before messages can be sent.", comment: "")
    }

    static var stytch_error_id_token_nonce_invalid: String {
        NSLocalizedString("stytch.error.idtokennonceinvalid", value: "The provided nonce does not match the nonce in the ID token.", comment: "")
    }

    static var stytch_error_email_template_not_found: String {
        NSLocalizedString("stytch.error.emailtemplatenotfound", value: "Email Template could not be found.", comment: "")
    }

    static var stytch_error_pkce_expected_code_verifier: String {
        NSLocalizedString("stytch.error.pkceexpectedcodeverifier", value: "This flow was started using a code_challenge but the authentication call is missing the corresponding code_verifier.", comment: "")
    }

    static var stytch_error_captcha_required: String {
        NSLocalizedString("stytch.error.captcharequired", value: "Captcha required", comment: "")
    }

    static var stytch_error_inactive_email: String {
        NSLocalizedString("stytch.error.inactiveemail", value: "The email address is marked as inactive. Please try another email address, or contact your admin if you think this is a mistake.", comment: "")
    }

    static var stytch_error_member_password_not_found: String {
        NSLocalizedString("stytch.error.memberpasswordnotfound", value: "Member password not found", comment: "")
    }

    static var stytch_error_too_many_unverified_factors: String {
        NSLocalizedString("stytch.error.toomanyunverifiedfactors", value: "We were unable to create a new auth factor. This user already has too many unverified factors.", comment: "")
    }

    static var stytch_error_server_unavailable: String {
        NSLocalizedString("stytch.error.serverunavailable", value: "Oops, something seems to have gone wrong. Please retry the request. If this issue persists, please reach out to support.", comment: "")
    }

    static var stytch_error_too_many_biometric_registrations_for_user: String {
        NSLocalizedString("stytch.error.toomanybiometricregistrationsforuser", value: "The provided user_id has reached the maximum allowed mobile biometric registrations. The maximum is 25.", comment: "")
    }

    static var stytch_error_duplicate_phone_number: String {
        NSLocalizedString("stytch.error.duplicatephonenumber", value: "A user with the specified phone number already exists for this project.", comment: "")
    }

    static var stytch_error_oauth_invalid_callback_request: String {
        NSLocalizedString("stytch.error.oauthinvalidcallbackrequest", value: "The OAuth callback request is invalid. Please reach out to the application developer for support.", comment: "")
    }

    static var stytch_error_intermediate_session_not_found: String {
        NSLocalizedString("stytch.error.intermediatesessionnotfound", value: "Intermediate session could not be found.", comment: "")
    }

    static var stytch_error_no_match_for_provided_magic_link_url: String {
        NSLocalizedString("stytch.error.nomatchforprovidedmagiclinkurl", value: "The magic_link_url in the request did not match any redirect URLs set for this project.", comment: "")
    }

    static var stytch_error_totp_code_already_authenticated: String {
        NSLocalizedString("stytch.error.totpcodealreadyauthenticated", value: "This TOTP code has already been authenticated. Please attempt with the next generated code.", comment: "")
    }

    static var stytch_error_invalid_session_duration_minutes: String {
        NSLocalizedString("stytch.error.invalidsessiondurationminutes", value: "session_duration_minutes is invalid, should be between 5 to 527040 minutes.", comment: "")
    }

    static var stytch_error_invalid_consumer_endpoint: String {
        NSLocalizedString("stytch.error.invalidconsumerendpoint", value: "This endpoint is only enabled for consumer projects.", comment: "")
    }

    static var stytch_error_cross_org_passwords_not_enabled: String {
        NSLocalizedString("stytch.error.crossorgpasswordsnotenabled", value: "Cross-organization passwords are not enabled for this project.", comment: "")
    }

    static var stytch_error_invalid_session_duration: String {
        NSLocalizedString("stytch.error.invalidsessionduration", value: "The submitted session duration exceeds the maximum session duration allowed for this project.", comment: "")
    }

    static var stytch_error_invalid_locale: String {
        NSLocalizedString("stytch.error.invalidlocale", value: "locale is invalid.", comment: "")
    }

    static var stytch_error_magic_link_not_found: String {
        NSLocalizedString("stytch.error.magiclinknotfound", value: "The magic link could not be authenticated, try sending another magic link.", comment: "")
    }

}
