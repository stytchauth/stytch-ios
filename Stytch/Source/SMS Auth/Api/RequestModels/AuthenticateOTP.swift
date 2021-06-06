import Foundation

struct AuthenticateOTPRequest: Codable {
    var method_id: String?
    var code: String?

    init(methodId: String?, code: String?){
        self.method_id = methodId
        self.code = code
    }
}
