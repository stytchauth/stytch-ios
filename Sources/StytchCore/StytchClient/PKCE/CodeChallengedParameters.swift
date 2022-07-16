import Foundation

struct CodeChallengedParameters<T: Encodable>: Encodable {
    private enum CodingKeys: String, CodingKey { case codeChallenge, codeChallengeMethod }

    let codeChallenge: String
    let codeChallengeMethod: String
    let wrapped: T

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try wrapped.encode(to: encoder)

        try container.encode(codeChallenge, forKey: .codeChallenge)
        try container.encode(codeChallengeMethod, forKey: .codeChallengeMethod)
    }
}
