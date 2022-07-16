import Foundation

struct CodeVerifierParameters<T: Encodable>: Encodable {
    private enum CodingKeys: String, CodingKey { case codeVerifier }

    let codeVerifier: String
    let wrapped: T

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try wrapped.encode(to: encoder)

        try container.encode(codeVerifier, forKey: .codeVerifier)
    }
}
