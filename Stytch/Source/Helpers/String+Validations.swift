//
//  String+Validations.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-20.
//

import Foundation

extension String {
    
    var isValidEmail: Bool {
        get {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: self)
        }
    }
    
    var isValidPhoneNumber: Bool {
        get {
            let phoneRegEx = "\\+(9[976]\\d|8[987530]\\d|6[987]\\d|5[90]\\d|42\\d|3[875]\\d|2[98654321]\\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)\\d{1,14}$"

            let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
            return phonePred.evaluate(with: self)
        }
    }

    var isValidOTP: Bool {
        get {
            let otpRegEx = "[0-9]{6}$"

            let otpPred = NSPredicate(format:"SELF MATCHES %@", otpRegEx)
            return otpPred.evaluate(with: self)
        }
    }

}
