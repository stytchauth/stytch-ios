// Generated using Sourcery 1.8.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

// MARK: - create Callback
public extension StytchClient.Passwords {
    func create(parameters: PasswordParameters, completion: @escaping Completion<CreateResponse>) {
        Task {
            do {
                completion(.success(try await create(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - create Combine
public extension StytchClient.Passwords {
    /// Create a new user with a password and an authenticated session for the user if requested. If a user with this email already exists in the project, an error will be returned.
    /// 
    /// Existing passwordless users who wish to create a password need to go through the reset password flow.
    func create(parameters: PasswordParameters) -> AnyPublisher<CreateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await create(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}

import Combine
import Foundation

// MARK: - authenticate Callback
public extension StytchClient.Passwords {
    func authenticate(parameters: PasswordParameters, completion: @escaping Completion<AuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - authenticate Combine
public extension StytchClient.Passwords {
    /// Authenticate a user with their email address and password. This method verifies that the user has a password currently set, and that the entered password is correct.
    /// 
    /// There are two instances where the endpoint will return a reset_password error even if they enter their previous password:
    /// 1. The user’s credentials appeared in the HaveIBeenPwned dataset.
    ///   a. We force a password reset to ensure that the user is the legitimate owner of the email address, and not a malicious actor abusing the compromised credentials.
    /// 2. The user used email based authentication (e.g. Magic Links, Google OAuth) for the first time, and had not previously verified their email address for password based login.
    ///   a. We force a password reset in this instance in order to safely deduplicate the account by email address, without introducing the risk of a pre-hijack account takeover attack.
    func authenticate(parameters: PasswordParameters) -> AnyPublisher<AuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await authenticate(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}

import Combine
import Foundation

// MARK: - resetByEmailStart Callback
public extension StytchClient.Passwords {
    func resetByEmailStart(parameters: ResetByEmailStartParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmailStart(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - resetByEmailStart Combine
public extension StytchClient.Passwords {
    /// Initiates a password reset for the email address provided. This will trigger an email to be sent to the address, containing a magic link that will allow them to set a new password and authenticate.
    func resetByEmailStart(parameters: ResetByEmailStartParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmailStart(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}

import Combine
import Foundation

// MARK: - resetByEmail Callback
public extension StytchClient.Passwords {
    func resetByEmail(parameters: ResetByEmailParameters, completion: @escaping Completion<AuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmail(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - resetByEmail Combine
public extension StytchClient.Passwords {
    /// Reset the user’s password and authenticate them. This endpoint checks that the magic link token is valid, hasn’t expired, or already been used – and can optionally require additional security settings, such as the IP address and user agent matching the initial reset request.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the user is authenticated.
    func resetByEmail(parameters: ResetByEmailParameters) -> AnyPublisher<AuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmail(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}

import Combine
import Foundation

// MARK: - strengthCheck Callback
public extension StytchClient.Passwords {
    func strengthCheck(parameters: StrengthCheckParameters, completion: @escaping Completion<StrengthCheckResponse>) {
        Task {
            do {
                completion(.success(try await strengthCheck(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - strengthCheck Combine
public extension StytchClient.Passwords {
    /// This method allows you to check whether or not the user’s provided password is valid, and to provide feedback to the user on how to increase the strength of their password.
    /// 
    /// Passwords are considered invalid if either of the following is true:
    /// 
    /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2.
    /// 2. The password is present in the HaveIBeenPwned dataset.
    /// 
    /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password. If you do not pass the email, it is possible that the password will evaluate as valid – but will fail with a weak_password error when used in the ``StytchClient/Passwords-swift.struct/create(parameters:)`` method.
    /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors that feedback provided by the zxcvbn library.
    func strengthCheck(parameters: StrengthCheckParameters) -> AnyPublisher<StrengthCheckResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await strengthCheck(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
