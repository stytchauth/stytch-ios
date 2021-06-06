import Foundation

struct SendOTPBySMSRequest: Codable {
    var phone_number: String?
    var expiration_minutes: Int?
}
