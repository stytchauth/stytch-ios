import Foundation

func generateNewEmail() -> String {
    let uuid = NSUUID().uuidString
    return "test+\(uuid)@stytch.com"
}

func generatePassword() -> String {
    let randomCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<14).map{ _ in randomCharacters.randomElement()! })
}
