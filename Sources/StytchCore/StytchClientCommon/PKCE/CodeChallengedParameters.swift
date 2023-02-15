import Foundation

struct CodeChallengedParameters<T: Encodable>: Encodable {
    let codingPrefix: String?
    let codeChallenge: String
    let codeChallengeMethod: String
    let wrapped: T

    init(codingPrefix: String? = nil, codeChallenge: String, codeChallengeMethod: String, wrapped: T) {
        self.codingPrefix = codingPrefix
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.wrapped = wrapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try wrapped.encode(to: encoder)

        try container.encode(codeChallenge, forKey: .codeChallenge(prefix: codingPrefix))
        try container.encode(codeChallengeMethod, forKey: .codeChallengeMethod(prefix: codingPrefix))
    }
}

extension CodeChallengedParameters {
    private struct CodingKeys: CodingKey {
        let prefix: String?
        let rawValue: String
        let intValue: Int? = nil

        var stringValue: String {
            [prefix, rawValue].compactMap { $0 }.joined(separator: "_")
        }

        static func codeChallenge(prefix: String?) -> Self {
            .init(prefix: prefix, rawValue: "code_challenge")
        }

        static func codeChallengeMethod(prefix: String?) -> Self {
            .init(prefix: prefix, rawValue: "code_challenge_method")
        }

        private init(prefix: String?, rawValue: String) {
            self.prefix = prefix
            self.rawValue = rawValue
        }

        init?(intValue: Int) {
            return nil
        }

        init?(stringValue: String) {
            return nil
        }
    }
}
