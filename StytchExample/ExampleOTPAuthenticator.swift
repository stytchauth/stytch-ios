//
//  ExampleOTPAuthenticator.swift
//  StytchExample
//
//  Created by Ethan Furstoss on 7/7/21.
//

import Foundation
import Stytch

class ExampleOTPAuthenticator: StytchOTPAuthenticator{
    func authenticateOTP(_ code: String, methodId: String, success: @escaping (AuthenticatedOTPResponse) -> (), failure: @escaping (StytchError) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = AuthenticatedOTPResponse(userId: "userId", requestId: "requestId", methodId: "methodId")
            success(response)
        }
    }
}
