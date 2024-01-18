import Foundation

func generateNewEmail() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let timestamp = dateFormatter.string(from: Date())
    return "test+\(timestamp)@stytch.com"
}
