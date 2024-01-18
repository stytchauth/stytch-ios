import Foundation

func generateNewEmail() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let timestamp = dateFormatter.string(from: Date())
    return "test+\(timestamp)@stytch.com"
}

func generatePassword() -> String {
    let randomCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<14).map{ _ in randomCharacters.randomElement()! })
}
